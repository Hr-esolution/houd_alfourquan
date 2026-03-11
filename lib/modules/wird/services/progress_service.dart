import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/progress_model.dart';

/// Service for managing user progress with Hive
/// Handles save, load, and backup
class ProgressService extends GetxService {
  static const String _boxName = 'wird_progress';
  static const String _progressKey = 'current_progress';
  
  Box<dynamic>? _box;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// Initialize Hive box
  Future<void> _initialize() async {
    try {
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
      debugPrint('✅ ProgressService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing ProgressService: $e');
      _isInitialized = false;
    }
  }

  /// Load progress from storage
  Future<ProgressModel> loadProgress() async {
    if (!_isInitialized) {
      debugPrint('⚠️ ProgressService not initialized, returning default');
      return ProgressModel();
    }

    try {
      final data = _box?.get(_progressKey);
      if (data == null) {
        debugPrint('📭 No saved progress, returning default');
        return ProgressModel();
      }

      final progress = ProgressModel.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
      debugPrint('📖 Loaded progress: Surah ${progress.lastSurah}, Ayah ${progress.lastAyah}');
      return progress;
    } catch (e) {
      debugPrint('❌ Error loading progress: $e');
      return ProgressModel(); // Return default on error
    }
  }

  /// Save progress to storage
  Future<void> saveProgress(ProgressModel progress) async {
    if (!_isInitialized) {
      debugPrint('⚠️ ProgressService not initialized, cannot save');
      return;
    }

    try {
      await _box?.put(_progressKey, progress.toJson());
      debugPrint('💾 Saved progress: Surah ${progress.lastSurah}, Ayah ${progress.lastAyah}');
    } catch (e) {
      debugPrint('❌ Error saving progress: $e');
      rethrow;
    }
  }

  /// Update last read position
  Future<void> updatePosition({
    required int surah,
    required int ayah,
  }) async {
    final progress = await loadProgress();
    final updated = progress.copyWith(
      lastSurah: surah,
      lastAyah: ayah,
      lastReadDate: ProgressModel.getTodayString(),
    );
    await saveProgress(updated);
  }

  /// Mark today as completed
  Future<void> markTodayCompleted() async {
    final progress = await loadProgress();
    final today = ProgressModel.getTodayString();
    
    if (!progress.completedDates.contains(today)) {
      final updated = progress.copyWith(
        completedDates: [...progress.completedDates, today],
      );
      await saveProgress(updated);
      debugPrint('✅ Marked today as completed');
    }
  }

  /// Check if user already completed today
  Future<bool> isTodayCompleted() async {
    final progress = await loadProgress();
    return progress.hasReadToday();
  }

  /// Update daily goal
  Future<void> updateDailyGoal(int goal) async {
    final progress = await loadProgress();
    final updated = progress.copyWith(dailyGoal: goal);
    await saveProgress(updated);
  }

  /// Update reminder time
  Future<void> updateReminderTime(String time) async {
    final progress = await loadProgress();
    final updated = progress.copyWith(reminderTime: time);
    await saveProgress(updated);
  }

  /// Reset progress (with backup)
  Future<void> resetProgress() async {
    final currentProgress = await loadProgress();
    
    // Archive old progress
    await _archiveProgress(currentProgress);
    
    // Reset to default
    await saveProgress(ProgressModel());
    debugPrint('🔄 Progress reset');
  }

  /// Archive old progress
  Future<void> _archiveProgress(ProgressModel progress) async {
    try {
      final archives = _box?.get('archives', defaultValue: []) as List<dynamic>;
      final newArchive = {
        'date': DateTime.now().toIso8601String(),
        'progress': progress.toJson(),
      };
      archives.add(newArchive);
      
      // Keep only last 10 archives
      if (archives.length > 10) {
        archives.removeAt(0);
      }
      
      await _box?.put('archives', archives);
      debugPrint('📦 Archived old progress');
    } catch (e) {
      debugPrint('❌ Error archiving progress: $e');
    }
  }

  /// Get progress history
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final archives = _box?.get('archives', defaultValue: []) as List<dynamic>;
      return archives.map((a) => Map<String, dynamic>.from(a as Map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting history: $e');
      return [];
    }
  }

  /// Clear all data
  Future<void> clearAll() async {
    try {
      await _box?.clear();
      debugPrint('🗑️ All progress data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }

  /// Get storage stats
  Future<Map<String, int>> getStats() async {
    try {
      final progress = await loadProgress();
      return {
        'completed_days': progress.completedDates.length,
        'current_surah': progress.lastSurah,
        'current_ayah': progress.lastAyah,
        'daily_goal': progress.dailyGoal,
      };
    } catch (e) {
      return {};
    }
  }
}
