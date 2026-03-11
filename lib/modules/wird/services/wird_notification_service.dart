import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';
import 'progress_service.dart';

/// Service for managing daily Wird notifications
/// Uses flutter_local_notifications for local reminders
class WirdNotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final ProgressService _progressService = ProgressService();

  // Notification channel IDs
  static const String _dailyReminderChannel = 'wird_daily_reminder';
  static const int _dailyReminderId = 1001;

  // Initialized flag
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// Initialize notification service
  Future<void> _initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: false,
      );

      // Combined initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create Android notification channel
      await _createNotificationChannel();

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;
      debugPrint('✅ WirdNotificationService initialized');

      // Schedule daily reminder
      await scheduleDailyReminder();
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
      _isInitialized = false;
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _dailyReminderChannel,
      'Rappel Wird Quotidien',
      description: 'Notification quotidienne pour la lecture du Wird',
      importance: Importance.high,
      showBadge: true,
      enableVibration: true,
      enableLights: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Android 13+ requires explicit permission
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS permissions
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');
    // Navigate to Wird screen (handled by app routing)
  }

  /// Schedule daily reminder at user's preferred time
  Future<void> scheduleDailyReminder() async {
    if (!_isInitialized) {
      debugPrint('⚠️ Notification service not initialized');
      return;
    }

    try {
      // Load user's preferred reminder time
      final progress = await _progressService.loadProgress();
      final reminderTime = progress.reminderTime ?? '21:00';

      // Parse time
      final timeParts = reminderTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Schedule at specified time daily
      await _notifications.zonedSchedule(
        _dailyReminderId,
        'Votre Wird Quotidien',
        'Il est temps de lire votre portion quotidienne du Coran',
        _nextInstanceOfTime(hour, minute),
        await _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'wird_reminder',
      );

      debugPrint('📅 Daily reminder scheduled for $reminderTime');
    } catch (e) {
      debugPrint('❌ Error scheduling reminder: $e');
    }
  }

  /// Get next occurrence of specified time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Get notification details
  Future<NotificationDetails> _notificationDetails() async {
    const androidDetails = AndroidNotificationDetails(
      _dailyReminderChannel,
      'Rappel Wird Quotidien',
      channelDescription: 'Notification quotidienne pour la lecture du Wird',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: false,
      category: AndroidNotificationCategory.reminder,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      enableLights: true,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'wird_reminder',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Cancel daily reminder
  Future<void> cancelReminder() async {
    try {
      await _notifications.cancel(_dailyReminderId);
      debugPrint('🔕 Daily reminder cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling reminder: $e');
    }
  }

  /// Update reminder time
  Future<void> updateReminderTime(String newTime) async {
    try {
      // Cancel existing reminder
      await cancelReminder();

      // Update in progress service
      await _progressService.updateReminderTime(newTime);

      // Schedule new reminder
      await scheduleDailyReminder();

      debugPrint('⏰ Reminder time updated to $newTime');
    } catch (e) {
      debugPrint('❌ Error updating reminder time: $e');
    }
  }

  /// Show instant notification (for testing)
  Future<void> showTestNotification() async {
    if (!_isInitialized) return;

    try {
      await _notifications.show(
        9999,
        'Test Wird Notification',
        'This is a test notification for the Wird system',
        await _notificationDetails(),
        payload: 'test_notification',
      );

      debugPrint('✅ Test notification shown');
    } catch (e) {
      debugPrint('❌ Error showing test notification: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.areNotificationsEnabled();
        return granted ?? false;
      }

      return true; // Assume enabled on iOS
    } catch (e) {
      debugPrint('❌ Error checking notification status: $e');
      return false;
    }
  }

  /// Request notification permission (manual)
  Future<bool> requestPermission() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error requesting permission: $e');
      return false;
    }
  }
}
