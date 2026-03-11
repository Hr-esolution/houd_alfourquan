import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/wird_model.dart';
import '../models/progress_model.dart';
import '../models/ayah_model.dart';
import '../repositories/quran_repository.dart';
import 'progress_service.dart';

/// Service for calculating and managing daily Wird
/// Core algorithm for portion generation
class WirdService extends GetxService {
  final QuranRepository _quranRepo = QuranRepository();
  final ProgressService _progressService = ProgressService();

  /// Calculate today's Wird based on user progress
  Future<WirdModel> calculateDailyWird() async {
    debugPrint('📖 Calculating daily Wird...');

    // Load progress
    final progress = await _progressService.loadProgress();
    
    // Check if user already read today
    if (progress.hasReadToday()) {
      debugPrint('✅ User already read today, loading existing Wird');
      // Could load from history here
    }

    // Calculate start position
    int startSurah = progress.lastSurah;
    int startAyah = progress.lastAyah + 1; // Next ayah after last read

    debugPrint('📍 Starting from: Surah $startSurah, Ayah $startAyah');

    // Check if we're at the end of Quran
    if (_quranRepo.isEndOfQuran(startSurah, startAyah)) {
      debugPrint('🎉 User completed the Quran!');
      return _createKhatmWird();
    }

    // Validate start position
    final isValid = await _quranRepo.isValidPosition(startSurah, startAyah);
    if (!isValid) {
      debugPrint('⚠️ Invalid position, resetting to 1:1');
      startSurah = 1;
      startAyah = 1;
    }

    // Get the range of ayahs
    List<AyahModel> verses;
    try {
      verses = await _quranRepo.getAyahRange(
        startSurah: startSurah,
        startAyah: startAyah,
        count: progress.dailyGoal,
      );
    } catch (e) {
      debugPrint('❌ Error getting ayah range: $e');
      verses = [];
    }

    // Handle edge case: not enough ayahs left
    if (verses.isEmpty) {
      debugPrint('⚠️ No ayahs found, checking if end of Quran');
      if (_quranRepo.isEndOfQuran(startSurah, startAyah)) {
        return _createKhatmWird();
      }
      // Reset to beginning
      startSurah = 1;
      startAyah = 1;
      verses = await _quranRepo.getAyahRange(
        startSurah: startSurah,
        startAyah: startAyah,
        count: progress.dailyGoal,
      );
    }

    // Calculate end position
    final lastVerse = verses.last;
    final endSurah = lastVerse.surahNumber;
    final endAyah = lastVerse.ayahNumber;

    debugPrint('📖 Wird calculated: $startSurah:$startAyah → $endSurah:$endAyah (${verses.length} verses)');

    // Create WirdModel
    return WirdModel(
      date: ProgressModel.getTodayString(),
      startSurah: startSurah,
      startAyah: startAyah,
      endSurah: endSurah,
      endAyah: endAyah,
      verses: verses,
      isCompleted: false,
      isQuranComplete: false,
    );
  }

  /// Create a special Wird for Quran completion
  WirdModel _createKhatmWird() {
    return WirdModel(
      date: ProgressModel.getTodayString(),
      startSurah: 114,
      startAyah: 6,
      endSurah: 114,
      endAyah: 6,
      verses: [],
      isCompleted: false,
      isQuranComplete: true,
    );
  }

  /// Mark Wird as completed and update progress
  Future<void> completeWird(WirdModel wird) async {
    if (wird.verses.isEmpty) {
      debugPrint('⚠️ Cannot complete empty Wird');
      return;
    }

    debugPrint('✅ Completing Wird: ${wird.verses.length} verses');

    // Update progress to end position
    await _progressService.updatePosition(
      surah: wird.endSurah,
      ayah: wird.endAyah,
    );

    // Mark today as completed
    await _progressService.markTodayCompleted();

    debugPrint('✅ Progress updated to Surah ${wird.endSurah}, Ayah ${wird.endAyah}');
  }

  /// Restart reading from beginning
  Future<void> restartReading() async {
    debugPrint('🔄 Restarting reading from beginning');
    await _progressService.updatePosition(surah: 1, ayah: 0);
  }

  /// Get reading progress percentage
  Future<double> getProgressPercentage() async {
    final progress = await _progressService.loadProgress();
    
    // Rough estimate: (current_surah / 114) * 100
    // More accurate would require counting total ayahs read
    final percentage = (progress.lastSurah / QuranRepository.totalSurahs) * 100;
    return percentage.clamp(0, 100);
  }

  /// Get estimated days to complete Quran
  Future<int> getEstimatedDaysRemaining() async {
    final progress = await _progressService.loadProgress();
    final remainingSurahs = QuranRepository.totalSurahs - progress.lastSurah;
    
    // Estimate: average 10 ayahs per surah, dailyGoal ayahs per day
    final remainingAyahs = remainingSurahs * 10; // Rough estimate
    final days = (remainingAyahs / progress.dailyGoal).ceil();
    
    return days.clamp(0, 365);
  }

  /// Get streak (consecutive days of reading)
  Future<int> getStreak() async {
    final progress = await _progressService.loadProgress();
    final completedDates = progress.completedDates;
    
    if (completedDates.isEmpty) return 0;

    // Sort dates descending
    final sorted = completedDates
        .map((d) => DateTime.parse(d))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 1;
    for (var i = 0; i < sorted.length - 1; i++) {
      final diff = sorted[i].difference(sorted[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        break; // Streak broken
      }
    }

    return streak;
  }

  /// Validate daily goal
  bool isValidDailyGoal(int goal) {
    return goal >= 1 && goal <= 100; // Reasonable limits
  }

  /// Get recommended daily goal based on available time
  int getRecommendedGoal(String timeAvailable) {
    // 5 minutes = 10 ayahs
    // 10 minutes = 20 ayahs
    // 15 minutes = 30 ayahs
    // 20 minutes = 40 ayahs
    switch (timeAvailable) {
      case '5min':
        return 10;
      case '10min':
        return 20;
      case '15min':
        return 30;
      case '20min':
        return 40;
      default:
        return 20; // Default
    }
  }
}
