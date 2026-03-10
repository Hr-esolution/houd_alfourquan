import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';

class AdhanController extends GetxController {
  final GetStorage _storage = GetStorage();
  final AudioPlayer _player = AudioPlayer();

  // Adhan locaux disponibles dans assets/audio/adhan
  static const List<Map<String, String>> localAdhans = [
    {
      'id': '1',
      'name': 'Adhan 1',
      'name_ar': 'أذان 1',
      'file': 'adhan1.mp3',
    },
    {
      'id': '2',
      'name': 'Adhan 2',
      'name_ar': 'أذان 2',
      'file': 'adhan2.mp3',
    },
    {
      'id': '3',
      'name': 'Adhan 3',
      'name_ar': 'أذان 3',
      'file': 'adhan3.mp3',
    },
    {
      'id': '4',
      'name': 'Adhan 4',
      'name_ar': 'أذان 4',
      'file': 'adhan4.mp3',
    },
    {
      'id': '5',
      'name': 'Adhan 5',
      'name_ar': 'أذان 5',
      'file': 'adhan5.mp3',
    },
    {
      'id': '6',
      'name': 'Adhan 6',
      'name_ar': 'أذان 6',
      'file': 'adhan6.mp3',
    },
  ];

  // Notification IDs par prière
  static const Map<String, int> prayerNotificationIds = {
    'fajr': 1,
    'dhuhr': 2,
    'asr': 3,
    'maghrib': 4,
    'isha': 5,
  };

  // Paramètres par prière
  Map<String, PrayerAdhanSettings> prayerSettings = {};

  // Lecture preview
  bool isPlayingPreview = false;
  String previewAdhanId = '';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final data = _storage.read('adhan_settings');
      
      if (data != null) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(data);
        prayerSettings = map.map((key, value) {
          return MapEntry(
            key,
            PrayerAdhanSettings.fromMap(Map<String, dynamic>.from(value)),
          );
        });
      } else {
        // Valeurs par défaut - utilise les adhans locaux
        prayerSettings = {
          'fajr': PrayerAdhanSettings(
            prayerName: 'fajr',
            isEnabled: true,
            adhanSource: 'local',
            adhanId: '1',
          ),
          'dhuhr': PrayerAdhanSettings(
            prayerName: 'dhuhr',
            isEnabled: true,
            adhanSource: 'local',
            adhanId: '2',
          ),
          'asr': PrayerAdhanSettings(
            prayerName: 'asr',
            isEnabled: true,
            adhanSource: 'local',
            adhanId: '3',
          ),
          'maghrib': PrayerAdhanSettings(
            prayerName: 'maghrib',
            isEnabled: true,
            adhanSource: 'local',
            adhanId: '4',
          ),
          'isha': PrayerAdhanSettings(
            prayerName: 'isha',
            isEnabled: true,
            adhanSource: 'local',
            adhanId: '5',
          ),
        };
        await _saveSettings();
      }
      
      debugPrint('✅ Adhan settings loaded: ${prayerSettings.length} prières');
      update();
    } catch (e) {
      debugPrint('❌ Error loading adhan settings: $e');
      // Initialiser avec valeurs par défaut en cas d'erreur
      _loadDefaultSettings();
    }
  }

  void _loadDefaultSettings() {
    prayerSettings = {
      'fajr': PrayerAdhanSettings(
        prayerName: 'fajr',
        isEnabled: true,
        adhanSource: 'local',
        adhanId: '1',
      ),
      'dhuhr': PrayerAdhanSettings(
        prayerName: 'dhuhr',
        isEnabled: true,
        adhanSource: 'local',
        adhanId: '2',
      ),
      'asr': PrayerAdhanSettings(
        prayerName: 'asr',
        isEnabled: true,
        adhanSource: 'local',
        adhanId: '3',
      ),
      'maghrib': PrayerAdhanSettings(
        prayerName: 'maghrib',
        isEnabled: true,
        adhanSource: 'local',
        adhanId: '4',
      ),
      'isha': PrayerAdhanSettings(
        prayerName: 'isha',
        isEnabled: true,
        adhanSource: 'local',
        adhanId: '5',
      ),
    };
    update();
  }

  Future<void> _saveSettings() async {
    try {
      final data = prayerSettings.map((key, value) {
        return MapEntry(key, value.toMap());
      });
      await _storage.write('adhan_settings', data);
      debugPrint('💾 Adhan settings saved');
    } catch (e) {
      debugPrint('❌ Error saving adhan settings: $e');
    }
  }

  Future<void> togglePrayerAdhan(String prayerName) async {
    if (!prayerSettings.containsKey(prayerName)) return;

    final settings = prayerSettings[prayerName]!;
    prayerSettings[prayerName] = PrayerAdhanSettings(
      prayerName: prayerName,
      isEnabled: !settings.isEnabled,
      adhanSource: settings.adhanSource,
      adhanId: settings.adhanId,
    );

    await _saveSettings();
    update(['adhan_$prayerName']);

    // Reprogrammer les notifications
    _rescheduleNotifications();

    Get.snackbar(
      settings.isEnabled ? 'Adhan désactivé' : 'Adhan activé',
      'Adhan ${prayerName.capitalize} ${settings.isEnabled ? 'désactivé' : 'activé'} ✓',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> setAdhanForPrayer(String prayerName, String adhanId, String source) async {
    if (!prayerSettings.containsKey(prayerName)) return;

    prayerSettings[prayerName] = PrayerAdhanSettings(
      prayerName: prayerName,
      isEnabled: true,
      adhanSource: source,
      adhanId: adhanId,
    );

    await _saveSettings();
    update(['adhan_$prayerName']);
    _rescheduleNotifications();
  }

  Future<void> previewAdhan(String adhanId, String source) async {
    try {
      // Stop current preview
      if (isPlayingPreview) {
        await _player.stop();
        isPlayingPreview = false;
        previewAdhanId = '';
        update(['preview_btn_$previewAdhanId']);
        return;
      }

      final path = 'assets/audio/adhan/adhan$adhanId.mp3';
      await _player.setAsset(path);
      await _player.play();
      
      isPlayingPreview = true;
      previewAdhanId = adhanId;
      update(['preview_btn_$adhanId']);

      // Listen for completion
      _player.playerStateStream.firstWhere((state) => !state.playing).then((_) {
        isPlayingPreview = false;
        previewAdhanId = '';
        update(['preview_btn_$adhanId']);
      });

      debugPrint('▶️ Preview adhan: adhan$adhanId.mp3');
    } catch (e) {
      debugPrint('❌ Preview error: $e');
      Get.snackbar('Erreur', 'Erreur de lecture: ${e.toString()}');
    }
  }

  Future<void> playAdhanForPrayer(String prayerName) async {
    try {
      final settings = prayerSettings[prayerName];
      if (settings == null || !settings.isEnabled) {
        debugPrint('🔕 Adhan not enabled for $prayerName');
        return;
      }

      // Stop any current playback
      await _player.stop();

      final path = 'assets/audio/adhan/adhan${settings.adhanId}.mp3';
      await _player.setAsset(path);
      await _player.play();
      
      debugPrint('🔊 Playing adhan for $prayerName: adhan${settings.adhanId}.mp3');
    } catch (e) {
      debugPrint('❌ Play adhan error: $e');
    }
  }

  void _rescheduleNotifications() {
    // Cette méthode sera appelée par PrayerService
    // Elle doit informer PrayerService de mettre à jour les notifications
    debugPrint('📅 Rescheduling notifications based on adhan settings');
    // PrayerService écoutera les changements via Get.find<AdhanController>()
  }

  String getAdhanPath(String adhanId, String source) {
    return 'assets/audio/adhan/adhan$adhanId.mp3';
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}

class PrayerAdhanSettings {
  final String prayerName;
  final bool isEnabled;
  final String adhanSource;
  final String adhanId;

  PrayerAdhanSettings({
    required this.prayerName,
    required this.isEnabled,
    required this.adhanSource,
    required this.adhanId,
  });

  factory PrayerAdhanSettings.fromMap(Map<String, dynamic> map) {
    return PrayerAdhanSettings(
      prayerName: map['prayerName'] ?? '',
      isEnabled: map['enabled'] ?? false,
      adhanSource: map['source'] ?? 'local',
      adhanId: map['adhanId'] ?? 'default',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prayerName': prayerName,
      'enabled': isEnabled,
      'source': adhanSource,
      'adhanId': adhanId,
    };
  }
}
