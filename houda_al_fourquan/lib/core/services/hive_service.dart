import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _locationBoxName = 'location_data';
  static const String _settingsBoxName = 'settings';

  // Keys for location data
  static const String keyLatitude = 'latitude';
  static const String keyLongitude = 'longitude';
  static const String keyCity = 'city';
  static const String keyLastLocationUpdate = 'last_location_update';

  // Keys for settings
  static const String keyUseAutoLocation = 'use_auto_location';
  static const String keyPrayerNotifications = 'prayer_notifications';
  static const String keyAdhanSound = 'adhan_sound';
  static const String keyFajrReminder = 'fajr_reminder';
  static const String keyCalcMethod = 'calc_method';
  static const String keyAsrMethod = 'asr_method';
  static const String keyHijriAdjustment = 'hijri_adjustment';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';

  /// Initialize Hive boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox(_locationBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  /// Get location box
  Box<dynamic> get _locationBox => Hive.box(_locationBoxName);

  /// Get settings box
  Box<dynamic> get _settingsBox => Hive.box(_settingsBoxName);

  // ==================== LOCATION DATA ====================

  /// Check if location data exists in cache
  bool hasCachedLocation() {
    return _locationBox.containsKey(keyLatitude) &&
        _locationBox.containsKey(keyLongitude) &&
        _locationBox.containsKey(keyCity);
  }

  /// Get cached latitude
  double? getCachedLatitude() {
    return _locationBox.get(keyLatitude);
  }

  /// Get cached longitude
  double? getCachedLongitude() {
    return _locationBox.get(keyLongitude);
  }

  /// Get cached city name
  String? getCachedCity() {
    return _locationBox.get(keyCity);
  }

  /// Get last location update timestamp
  DateTime? getLastLocationUpdate() {
    final timestamp = _locationBox.get(keyLastLocationUpdate);
    if (timestamp == null) return null;
    return timestamp is DateTime
        ? timestamp
        : DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Save location data to cache
  Future<void> saveLocationData({
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    await _locationBox.put(keyLatitude, latitude);
    await _locationBox.put(keyLongitude, longitude);
    await _locationBox.put(keyCity, city);
    await _locationBox.put(keyLastLocationUpdate, DateTime.now());
  }

  /// Clear cached location data
  Future<void> clearLocationData() async {
    await _locationBox.delete(keyLatitude);
    await _locationBox.delete(keyLongitude);
    await _locationBox.delete(keyCity);
    await _locationBox.delete(keyLastLocationUpdate);
  }

  // ==================== SETTINGS ====================

  /// Check if auto location is enabled
  bool isAutoLocationEnabled() {
    return _settingsBox.get(keyUseAutoLocation, defaultValue: true);
  }

  /// Set auto location setting
  Future<void> setAutoLocation(bool enabled) async {
    await _settingsBox.put(keyUseAutoLocation, enabled);
  }

  /// Check if cache is older than specified duration
  bool isCacheExpired(Duration maxAge) {
    final lastUpdate = getLastLocationUpdate();
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    return now.difference(lastUpdate) > maxAge;
  }

  /// Get cache age in hours
  double getCacheAgeInHours() {
    final lastUpdate = getLastLocationUpdate();
    if (lastUpdate == null) return double.infinity;

    return DateTime.now().difference(lastUpdate).inHours.toDouble();
  }
}
