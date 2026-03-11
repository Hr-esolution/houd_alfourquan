import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';
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

  /// IDs de notification pour rappel 5 min avant
  static const Map<String, int> preAdhanNotificationIds = {
    'fajr': 11,
    'dhuhr': 12,
    'asr': 13,
    'maghrib': 14,
    'isha': 15,
  };

  /// Background task callback - MUST be top-level or static
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      debugPrint('🔔 Background task executed: $task');

      try {
        // Initialize notifications
        final notifications = FlutterLocalNotificationsPlugin();

        // Get prayer name from input data
        final prayerName = inputData?['prayerName'] ?? 'fajr';
        final type = inputData?['type'] ?? 'adhan';

        // Check if it's a pre-adhan notification
        if (type == 'pre_adhan') {
          // Show silent reminder notification
          const AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
            'adhan_channel',
            'Adhan Notifications',
            channelDescription: 'Prayer time adhan notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: false,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
            category: AndroidNotificationCategory.reminder,
          );

          const NotificationDetails notificationDetails = NotificationDetails(
            android: androidDetails,
          );

          await notifications.show(
            preAdhanNotificationIds[prayerName] ?? 11,
            'Rappel Prière',
            "Dans 5 minutes : ${_getPrayerNameFr(prayerName)}",
            notificationDetails,
            payload: 'pre_adhan_$prayerName',
          );

          debugPrint('✅ Pre-adhan reminder shown for $prayerName');
          return Future.value(true);
        }

        // Show adhan notification with sound
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'adhan_channel',
          'Adhan Notifications',
          channelDescription: 'Prayer time adhan notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('adhan'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
        );

        const NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails,
        );

        await notifications.show(
          prayerNotificationIds[prayerName] ?? 1,
          'Heure de la prière',
          "C'est l'heure de ${_getPrayerNameFr(prayerName)}",
          notificationDetails,
          payload: prayerName,
        );

        debugPrint('✅ Background notification shown for $prayerName');
        return Future.value(true);
      } catch (e) {
        debugPrint('❌ Background task error: $e');
        return Future.value(false);
      }
    });
  }

  /// Initialiser le service
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialiser timezone
    tz.initializeTimeZones();

    // Récupérer AdhanController
    if (Get.isRegistered<AdhanController>()) {
      _adhanController = Get.find<AdhanController>();
    }

    // Workmanager 0.9.x doesn't need manual initialization
    // It uses androidx.work.WorkManagerInitializer from AndroidManifest

    // Paramètres Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Paramètres iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

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

    // Créer le canal de notification
    await _createNotificationChannel();

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

  /// Créer le canal de notification Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'adhan_channel',
      'Adhan Notifications',
      description: 'Prayer time adhan notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan'),
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
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
      await flutterLocalNotificationsPlugin.cancel(preAdhanNotificationIds[prayerName] ?? 0);
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

    // Programmer notification 5 min avant avec Workmanager
    await _schedulePreAdhanNotification(prayerName, time);

    // Utiliser Workmanager pour le background (adhan)
    await Workmanager().registerOneOffTask(
      'adhan_$prayerName',
      'adhan_notification',
      initialDelay: tzDate.difference(tz.TZDateTime.now(tz.local)),
      inputData: {
        'prayerName': prayerName,
      },
    );

    // Also schedule with flutter_local_notifications as backup
    await _scheduleWithFlutterNotifications(prayerName, time, notificationId);

    debugPrint('📅 Scheduled $prayerName at ${time.toString()} with 5min pre-adhan');
  }

  /// Programmer notification 5 minutes avant l'adhan
  Future<void> _schedulePreAdhanNotification(
    String prayerName,
    DateTime time,
  ) async {
    final int? preAdhanId = preAdhanNotificationIds[prayerName];
    if (preAdhanId == null) return;

    // Calculer le temps 5 minutes avant
    final DateTime preAdhanTime = time.subtract(const Duration(minutes: 5));
    final tz.TZDateTime tzPreAdhanDate = tz.TZDateTime.from(preAdhanTime, tz.local);

    // Ne pas programmer dans le passé
    if (tzPreAdhanDate.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('⏰ Skipping pre-adhan for $prayerName - past time');
      return;
    }

    // Programmer avec Workmanager
    await Workmanager().registerOneOffTask(
      'pre_adhan_$prayerName',
      'pre_adhan_notification',
      initialDelay: tzPreAdhanDate.difference(tz.TZDateTime.now(tz.local)),
      inputData: {
        'prayerName': prayerName,
        'type': 'pre_adhan',
      },
    );

    // Programmer avec flutter_local_notifications
    await _schedulePreAdhanWithFlutter(prayerName, preAdhanTime, preAdhanId);
  }

  /// Schedule pre-adhan with flutter_local_notifications
  Future<void> _schedulePreAdhanWithFlutter(
    String prayerName,
    DateTime time,
    int notificationId,
  ) async {
    final tz.TZDateTime tzDate = tz.TZDateTime.from(time, tz.local);

    // Détails Android
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'adhan_channel',
      'Adhan Notifications',
      channelDescription: 'Prayer time adhan notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false, // Pas de son pour le rappel
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      category: AndroidNotificationCategory.reminder,
    );

    // Détails iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    // Détails combinés
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Programmer la notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Rappel Prière',
      "Dans 5 minutes : ${_getPrayerNameFr(prayerName)}",
      tzDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'pre_adhan_$prayerName',
    );
  }

  /// Schedule with flutter_local_notifications (backup method)
  Future<void> _scheduleWithFlutterNotifications(
    String prayerName,
    DateTime time,
    int notificationId,
  ) async {
    final tz.TZDateTime tzDate = tz.TZDateTime.from(time, tz.local);

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
      fullScreenIntent: true,
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
  }

  /// Annuler une notification
  Future<void> cancelPrayerNotification(String prayerName) async {
    final int? notificationId = prayerNotificationIds[prayerName];
    if (notificationId != null) {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
    // Cancel pre-adhan notification
    final int? preAdhanId = preAdhanNotificationIds[prayerName];
    if (preAdhanId != null) {
      await flutterLocalNotificationsPlugin.cancel(preAdhanId);
    }
    // Cancel workmanager tasks
    await Workmanager().cancelByUniqueName('adhan_$prayerName');
    await Workmanager().cancelByUniqueName('pre_adhan_$prayerName');
  }

  /// Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    await Workmanager().cancelAll();
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
  static String _getPrayerNameFr(String prayerName) {
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
