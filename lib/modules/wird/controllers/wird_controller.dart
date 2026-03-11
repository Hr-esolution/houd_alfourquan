import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/language_controller.dart';
import '../models/wird_model.dart';
import '../models/progress_model.dart';
import '../services/wird_service.dart';
import '../services/progress_service.dart';
import '../services/wird_notification_service.dart';

/// Controller for Daily Wird feature
/// Manages UI state and business logic
class WirdController extends GetxController {
  late WirdService _wirdService;
  late ProgressService _progressService;
  late WirdNotificationService _notificationService;
  late LanguageController _langController;

  // State variables
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<WirdModel?> _currentWird = Rx<WirdModel?>(null);
  final Rx<ProgressModel> _progress = ProgressModel().obs;
  final RxDouble _progressPercent = 0.0.obs;
  final RxInt _streak = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  WirdModel? get currentWird => _currentWird.value;
  ProgressModel get progress => _progress.value;
  double get progressPercent => _progressPercent.value;
  int get streak => _streak.value;
  String get currentLang => _langController.currentLang;

  @override
  void onInit() {
    super.onInit();
    _wirdService = WirdService();
    _progressService = ProgressService();
    _notificationService = WirdNotificationService();
    _langController = Get.find<LanguageController>();
    loadWird();
  }

  /// Load daily Wird
  Future<void> loadWird() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      debugPrint('📖 Loading Wird...');

      // Load progress
      _progress.value = await _progressService.loadProgress();

      // Calculate Wird
      _currentWird.value = await _wirdService.calculateDailyWird();

      // Calculate stats
      _progressPercent.value = await _wirdService.getProgressPercentage();
      _streak.value = await _wirdService.getStreak();

      debugPrint('✅ Wird loaded: ${_currentWird.value?.verseCount ?? 0} verses');
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erreur de chargement: $e';
      debugPrint('❌ Error loading Wird: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Mark Wird as completed
  Future<void> completeWird() async {
    if (_currentWird.value == null) {
      debugPrint('⚠️ No Wird to complete');
      return;
    }

    try {
      debugPrint('✅ Marking Wird as completed...');

      await _wirdService.completeWird(_currentWird.value!);

      // Update local state
      _progress.value = await _progressService.loadProgress();
      _progressPercent.value = await _wirdService.getProgressPercentage();

      Get.snackbar(
        'Succès',
        'Wird terminé ! Barakallahu fik',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('✅ Wird completed successfully');

      // Reload to get new Wird for next day
      await loadWird();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('❌ Error completing Wird: $e');
    }
  }

  /// Check if user already completed today
  bool isTodayCompleted() {
    return _progress.value.hasReadToday();
  }

  /// Restart reading from beginning
  Future<void> restartReading() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Recommencer la lecture ?'),
          content: const Text(
            'Voulez-vous vraiment recommencer la lecture du Coran depuis le début ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Recommencer'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _wirdService.restartReading();
        await loadWird();
        Get.snackbar(
          'Succès',
          'Lecture recommencée depuis le début',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('❌ Error restarting: $e');
    }
  }

  /// Update daily goal
  Future<void> updateDailyGoal(int goal) async {
    if (!_wirdService.isValidDailyGoal(goal)) {
      Get.snackbar(
        'Erreur',
        'Objectif invalide',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _progressService.updateDailyGoal(goal);
      _progress.value = await _progressService.loadProgress();
      await loadWird(); // Recalculate with new goal
      Get.snackbar(
        'Succès',
        'Objectif mis à jour: $goal versets/jour',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Update reminder time
  Future<void> updateReminderTime(String time) async {
    try {
      await _notificationService.updateReminderTime(time);
      _progress.value = await _progressService.loadProgress();
      Get.snackbar(
        'Succès',
        'Rappel programmé à $time',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Refresh Wird
  @override
  void refresh() async {
    await loadWird();
  }

  /// Get localized text for completion button
  String getCompleteButtonText() {
    if (_currentWird.value?.isQuranComplete == true) {
      switch (currentLang) {
        case 'ar':
          return 'ختمت القرآن';
        case 'en':
          return 'I Completed the Quran';
        case 'fr':
        default:
          return 'J\'ai complété le Coran';
      }
    }

    if (isTodayCompleted()) {
      switch (currentLang) {
        case 'ar':
          return 'تمت القراءة اليوم';
        case 'en':
          return 'Already Completed Today';
        case 'fr':
        default:
          return 'Déjà complété aujourd\'hui';
      }
    }

    switch (currentLang) {
      case 'ar':
        return 'أتممت الورد اليومي';
      case 'en':
        return 'Mark as Completed';
      case 'fr':
      default:
        return 'Marquer comme complété';
    }
  }

  /// Get localized welcome message
  String getWelcomeMessage() {
    if (_currentWird.value?.isQuranComplete == true) {
      switch (currentLang) {
        case 'ar':
          return 'مبارك! لقد ختمت القرآن';
        case 'en':
          return 'Congratulations! You completed the Quran';
        case 'fr':
        default:
          return 'Mabrouk ! Vous avez complété le Coran';
      }
    }

    if (isTodayCompleted()) {
      switch (currentLang) {
        case 'ar':
          return 'أحسنت! لقد أتممت ورد اليوم';
        case 'en':
          return 'Well done! You completed today\'s Wird';
        case 'fr':
        default:
          return 'Machallah ! Vous avez complété le Wird d\'aujourd\'hui';
      }
    }

    switch (currentLang) {
      case 'ar':
        return 'وردك اليومي';
      case 'en':
        return 'Your Daily Wird';
      case 'fr':
      default:
        return 'Votre Wird Quotidien';
    }
  }

  /// Get verse text based on current language
  String getVerseText(dynamic verse) {
    switch (currentLang) {
      case 'ar':
        return verse.textAr;
      case 'en':
        return verse.textEn;
      case 'fr':
      default:
        return verse.textFr;
    }
  }
}
