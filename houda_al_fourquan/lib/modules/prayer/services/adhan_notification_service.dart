import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../controllers/adhan_controller.dart';

/// Service de notification Adhan
/// Gère les notifications programmées pour chaque prière
class AdhanNotificationService {
  static final AdhanNotificationService _instance =
      AdhanNotificationService._internal();
  factory AdhanNotificationService() => _instance;
  AdhanNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AdhanController? _adhanController;
  bool _isInitialized = false;

  /// IDs de notification par prière
  static const Map<String, int> prayerNotificationIds = {
    'fajr': 1,
    'dhuhr': 2,
    'asr': 3,
    'maghrib': 4,
    'isha': 5,
  };

  /// Initialiser le service
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialiser timezone
    tz.initializeTimeZones();

    // Récupérer AdhanController
    if (Get.isRegistered<AdhanController>()) {
      _adhanController = Get.find<AdhanController>();
    }

    // Paramètres Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Paramètres iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    // Paramètres combinés
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialiser le plugin
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    // Demander les permissions (notifications + alarmes exactes)
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    final iosPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    _isInitialized = true;
    debugPrint('✅ AdhanNotificationService initialized');
  }

  /// Callback notification (background)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    debugPrint('🔔 Background notification: ${response.payload}');
  }

  /// Callback notification (foreground)
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      _adhanController?.playAdhanForPrayer(response.payload ?? '');
    }
  }

  /// Programmer une notification pour une prière
  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime time,
  }) async {
    if (!_isInitialized) await init();

    final int? notificationId = prayerNotificationIds[prayerName];
    if (notificationId == null) return;

    // Vérifier si adhan est activé
    final settings = _adhanController?.prayerSettings[prayerName];
    if (settings == null || !settings.isEnabled) {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      debugPrint('🔕 Adhan disabled for $prayerName');
      return;
    }

    // Convertir en TZDateTime
    final tz.TZDateTime tzDate = tz.TZDateTime.from(time, tz.local);

    // Ne pas programmer dans le passé
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('⏰ Skipping $prayerName - past time');
      return;
    }

    // Détails Android
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'adhan_channel',
          'Adhan Notifications',
          channelDescription: 'Prayer time adhan notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('adhan'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.alarm,
        );

    // Détails iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Détails combinés
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Programmer la notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Heure de la prière',
      "C'est l'heure de ${_getPrayerNameFr(prayerName)}",
      tzDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: prayerName,
    );

    debugPrint('📅 Scheduled $prayerName at ${time.toString()}');
  }

  /// Annuler une notification
  Future<void> cancelPrayerNotification(String prayerName) async {
    final int? notificationId = prayerNotificationIds[prayerName];
    if (notificationId != null) {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }

  /// Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Reprogrammer toutes les notifications
  Future<void> rescheduleAllNotifications(
    Map<String, DateTime> prayerTimes,
  ) async {
    if (!_isInitialized) await init();

    await cancelAllNotifications();

    for (final entry in prayerTimes.entries) {
      final settings = _adhanController?.prayerSettings[entry.key];
      if (settings != null && settings.isEnabled) {
        await schedulePrayerNotification(
          prayerName: entry.key,
          time: entry.value,
        );
      }
    }
  }

  /// Nom de la prière en français
  String _getPrayerNameFr(String prayerName) {
    switch (prayerName) {
      case 'fajr':
        return 'Fajr';
      case 'dhuhr':
        return 'Dhuhr';
      case 'asr':
        return 'Asr';
      case 'maghrib':
        return 'Maghrib';
      case 'isha':
        return 'Isha';
      default:
        return prayerName;
    }
  }
}
