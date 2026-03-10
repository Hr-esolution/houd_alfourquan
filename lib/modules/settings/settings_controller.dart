import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';

class SettingsController extends GetxController {
  // ==================== BOX NAMES & KEYS ====================
  static const String _settingsBoxName = 'settings';

  // Notification keys
  static const String keyPrayerNotifications = 'prayer_notifications';
  static const String keyAdhanSound = 'adhan_sound';
  static const String keyFajrReminder = 'fajr_reminder';

  // Prayer settings keys
  static const String keyCalcMethod = 'calc_method';
  static const String keyAsrMethod = 'asr_method';
  static const String keyHijriAdjustment = 'hijri_adjustment';

  // Appearance keys
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';

  // ==================== REACTIVE VARIABLES ====================

  // Notification settings
  final RxBool prayerNotifications = true.obs;
  final RxBool adhanSound = true.obs;
  final RxBool fajrReminder = true.obs;

  // Prayer settings
  final RxString calcMethod = 'Muslim World League'.obs;
  final RxString asrMethod = 'Standard (Shafi)'.obs;
  final RxBool hijriAdjustment = false.obs;

  // Appearance settings
  final RxBool darkMode = false.obs;
  final RxString language = 'English'.obs;

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    // Load settings after build is complete
    Future.microtask(() => loadSettings());
  }

  // ==================== SETTINGS PERSISTENCE ====================

  /// Load all settings from Hive
  Future<void> loadSettings() async {
    try {
      final box = Hive.box(_settingsBoxName);

      // Load notification settings
      prayerNotifications.value = box.get(
        keyPrayerNotifications,
        defaultValue: true,
      );
      adhanSound.value = box.get(keyAdhanSound, defaultValue: true);
      fajrReminder.value = box.get(keyFajrReminder, defaultValue: true);

      // Load prayer settings
      calcMethod.value = box.get(
        keyCalcMethod,
        defaultValue: 'Muslim World League',
      );
      asrMethod.value = box.get(keyAsrMethod, defaultValue: 'Standard (Shafi)');
      hijriAdjustment.value = box.get(keyHijriAdjustment, defaultValue: false);

      // Load appearance settings
      darkMode.value = box.get(keyDarkMode, defaultValue: false);
      language.value = box.get(keyLanguage, defaultValue: 'English');

      // Apply theme
      applyTheme();

      // Apply language
      applyLanguage();
    } catch (e) {
      Get.snackbar(
        'Error'.trx,
        'Failed to load settings: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Save a single setting to Hive immediately
  Future<void> _saveSingleSetting<T>(String key, T value) async {
    try {
      final box = Hive.box(_settingsBoxName);
      await box.put(key, value);
    } catch (e) {
      Get.snackbar(
        'Error'.trx,
        'Failed to save setting: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Save all settings to Hive
  Future<void> saveSettings() async {
    try {
      final box = Hive.box(_settingsBoxName);

      // Save notification settings
      await box.put(keyPrayerNotifications, prayerNotifications.value);
      await box.put(keyAdhanSound, adhanSound.value);
      await box.put(keyFajrReminder, fajrReminder.value);

      // Save prayer settings
      await box.put(keyCalcMethod, calcMethod.value);
      await box.put(keyAsrMethod, asrMethod.value);
      await box.put(keyHijriAdjustment, hijriAdjustment.value);

      // Save appearance settings
      await box.put(keyDarkMode, darkMode.value);
      await box.put(keyLanguage, language.value);
    } catch (e) {
      Get.snackbar(
        'Error'.trx,
        'Failed to save settings: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Reset all settings to default values
  Future<void> resetToDefaults() async {
    try {
      // Reset notification settings
      prayerNotifications.value = true;
      adhanSound.value = true;
      fajrReminder.value = true;

      // Reset prayer settings
      calcMethod.value = 'Muslim World League';
      asrMethod.value = 'Standard (Shafi)';
      hijriAdjustment.value = false;

      // Reset appearance settings
      darkMode.value = false;
      language.value = 'English';

      // Save defaults
      await saveSettings();

      // Apply changes
      applyTheme();
      applyLanguage();

      Get.snackbar(
        'Success'.trx,
        'Settings reset to defaults'.trx,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh UI
      update();
    } catch (e) {
      Get.snackbar(
        'Error'.trx,
        'Failed to reset settings: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== NOTIFICATION SETTINGS ====================

  /// Toggle prayer notifications with immediate update
  Future<void> togglePrayerNotifications(bool value) async {
    prayerNotifications.value = value;
    await _saveSingleSetting(keyPrayerNotifications, value);
    update();

    _showSettingStatusSnackbar(
      enabled: value,
      settingName: 'Prayer Notifications'.trx,
      enabledMessage: 'Prayer notifications enabled'.trx,
      disabledMessage: 'Prayer notifications disabled'.trx,
    );
  }

  /// Toggle adhan sound with immediate update
  Future<void> toggleAdhanSound(bool value) async {
    adhanSound.value = value;
    await _saveSingleSetting(keyAdhanSound, value);
    update();

    _showSettingStatusSnackbar(
      enabled: value,
      settingName: 'Adhan Sound'.trx,
      enabledMessage: 'Adhan sound enabled'.trx,
      disabledMessage: 'Adhan sound disabled'.trx,
    );
  }

  /// Toggle Fajr reminder with immediate update
  Future<void> toggleFajrReminder(bool value) async {
    fajrReminder.value = value;
    await _saveSingleSetting(keyFajrReminder, value);
    update();

    _showSettingStatusSnackbar(
      enabled: value,
      settingName: 'Fajr Reminder'.trx,
      enabledMessage: 'Fajr reminder enabled'.trx,
      disabledMessage: 'Fajr reminder disabled'.trx,
    );
  }

  // ==================== PRAYER SETTINGS ====================

  /// Set calculation method with immediate update
  Future<void> setCalculationMethod(String method) async {
    calcMethod.value = method;
    await _saveSingleSetting(keyCalcMethod, method);
    update();

    Get.snackbar(
      'Updated'.trx,
      'Calculation method: $method'.trx,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Set Asr method with immediate update
  Future<void> setAsrMethod(String method) async {
    asrMethod.value = method;
    await _saveSingleSetting(keyAsrMethod, method);
    update();

    Get.snackbar(
      'Updated'.trx,
      'Asr method: $method'.trx,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Toggle Hijri adjustment with immediate update
  Future<void> toggleHijriAdjustment(bool value) async {
    hijriAdjustment.value = value;
    await _saveSingleSetting(keyHijriAdjustment, value);
    update();

    _showSettingStatusSnackbar(
      enabled: value,
      settingName: 'Hijri Adjustment'.trx,
      enabledMessage: 'Hijri adjustment enabled'.trx,
      disabledMessage: 'Hijri adjustment disabled'.trx,
    );
  }

  /// Get calculation method index for dropdown
  int getCalculationMethodIndex() {
    final methods = [
      'Muslim World League',
      'Egyptian',
      'Karachi',
      'Umm al-Qura',
      'Dubai',
    ];
    return methods.indexOf(calcMethod.value);
  }

  /// Get Asr method index for dropdown
  int getAsrMethodIndex() {
    final methods = ['Standard (Shafi)', 'Hanafi'];
    return methods.indexOf(asrMethod.value);
  }

  // ==================== APPEARANCE SETTINGS ====================

  /// Toggle dark mode with immediate theme update
  Future<void> toggleDarkMode(bool value) async {
    darkMode.value = value;
    await _saveSingleSetting(keyDarkMode, value);
    update();
    applyTheme();

    _showSettingStatusSnackbar(
      enabled: value,
      settingName: 'Dark Mode'.trx,
      enabledMessage: 'Dark mode enabled'.trx,
      disabledMessage: 'Dark mode disabled'.trx,
    );
  }

  /// Set language with immediate update
  Future<void> setLanguage(String lang) async {
    language.value = lang;
    await _saveSingleSetting(keyLanguage, lang);
    update();
    applyLanguage();

    Get.snackbar(
      'Language Changed'.trx,
      'Language updated successfully'.trx,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Apply theme based on dark mode setting
  void applyTheme() {
    if (darkMode.value) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  /// Apply language setting
  void applyLanguage() {
    Locale locale;

    switch (language.value.toLowerCase()) {
      case 'arabic':
        locale = const Locale('ar', 'SA');
        break;
      case 'french':
        locale = const Locale('fr', 'FR');
        break;
      case 'urdu':
        locale = const Locale('ur', 'PK');
        break;
      default:
        locale = const Locale('en', 'US');
    }

    Get.updateLocale(locale);
  }

  // ==================== HELPER METHODS ====================

  /// Show status snackbar for toggle settings
  void _showSettingStatusSnackbar({
    required bool enabled,
    required String settingName,
    required String enabledMessage,
    required String disabledMessage,
  }) {
    Get.snackbar(
      enabled ? 'Enabled'.trx : 'Disabled'.trx,
      enabled ? enabledMessage : disabledMessage,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Check if notifications are enabled
  bool get isNotificationsEnabled => prayerNotifications.value;

  /// Check if adhan sound is enabled
  bool get isAdhanSoundEnabled => adhanSound.value;

  /// Check if dark mode is enabled
  bool get isDarkModeEnabled => darkMode.value;

  /// Get current language code
  String get languageCode {
    switch (language.value.toLowerCase()) {
      case 'arabic':
        return 'ar';
      case 'french':
        return 'fr';
      case 'urdu':
        return 'ur';
      default:
        return 'en';
    }
  }

  /// Show confirmation dialog before critical changes
  Future<bool> showConfirmationDialog({
    required String title,
    required String message,
  }) async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text(title.trx),
            content: Text(message.trx),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancel'.trx),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DT.or,
                  foregroundColor: DT.blanc,
                ),
                child: Text('Confirm'.trx),
              ),
            ],
          ),
        ) ??
        false;
  }
}
