import 'dart:async';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/services/hive_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/osm_service.dart';
import '../../prayer/services/prayer_calculation_service.dart';

class HomeController extends GetxController {
  final HiveService hiveService = Get.find<HiveService>();
  final LocationService locationService = Get.find<LocationService>();
  final OSMService osmService = Get.find<OSMService>();
  final PrayerCalculationService prayerService = PrayerCalculationService();

  // Make services public for city_widget access
  HiveService get hiveServicePublic => hiveService;
  OSMService get osmServicePublic => osmService;
  PrayerCalculationService get prayerServicePublic => prayerService;

  // State variables (GetBuilder compatible - no Rx)
  String city = "Loading...";
  String hijriDate = "";
  String gregorianDate = "";
  Map<String, DateTime> prayerTimes = {};
  String nextPrayerName = "";
  String countdown = "";

  // Loading states
  bool isLoading = false;
  bool isUpdatingLocation = false;

  // Search
  bool isSearching = false;
  List<Map<String, dynamic>> searchResults = [];
  String searchQuery = "";

  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    _startCountdown();
    loadData();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  /// Main load method - Cache first, GPS only if needed
  Future<void> loadData() async {
    isLoading = true;
    update();

    final cachedLat = hiveService.getCachedLatitude();
    final cachedLng = hiveService.getCachedLongitude();
    final cachedCity = hiveService.getCachedCity();
    final hasValidCache = cachedLat != null &&
        cachedLng != null &&
        cachedCity != null &&
        cachedCity.trim().isNotEmpty;

    try {
      // 1. Try to load from cache first (fast)
      if (hasValidCache) {
        _loadFromCache();
        _recalculatePrayerTimes();
        _updateDates();
        isLoading = false;
        update();

        // Optional: refresh in background if cache is old
        if (hiveService.isAutoLocationEnabled() &&
            hiveService.isCacheExpired(const Duration(hours: 12))) {
          _fetchLocationData().catchError((_) {});
        }
        return; // Exit early - cache loaded successfully
      }

      // 2. Cache empty/invalid - fetch from GPS (first install only)
      await _fetchLocationData();
      _updateDates();
      isLoading = false;
      update();
      
    } catch (e) {
      // GPS failed - try cache as fallback
      if (hasValidCache) {
        _loadFromCache();
        _recalculatePrayerTimes();
        city = hiveService.getCachedCity() ?? "Position non disponible";
      } else {
        // No cache and GPS failed - use default
        city = "Position non disponible";
        _loadDefaultData();
      }
      isLoading = false;
      update();
    }
  }

  /// Load default data (fallback)
  void _loadDefaultData() {
    // Use Paris as default
    final defaultLat = 48.8566;
    final defaultLng = 2.3522;
    
    final prayerTimesResult = prayerService.calculate(
      date: DateTime.now(),
      coordinates: Coordinates(defaultLat, defaultLng),
    );

    if (prayerTimesResult != null) {
      prayerTimes = {
        'fajr': prayerTimesResult.fajr,
        'dhuhr': prayerTimesResult.dhuhr,
        'asr': prayerTimesResult.asr,
        'maghrib': prayerTimesResult.maghrib,
        'isha': prayerTimesResult.isha,
      };
    }
    
    _updateDates();
  }

  /// Load data from Hive cache (no API calls)
  void _loadFromCache() {
    final lat = hiveService.getCachedLatitude();
    final lng = hiveService.getCachedLongitude();
    final cachedCity = hiveService.getCachedCity();

    if (cachedCity != null) {
      city = cachedCity;
    }

    if (lat != null && lng != null) {
      // Recalculate prayer times from cached coordinates
      final prayerTimesResult = prayerService.calculate(
        date: DateTime.now(),
        coordinates: Coordinates(lat, lng),
      );

      if (prayerTimesResult != null) {
        prayerTimes = {
          'fajr': prayerTimesResult.fajr,
          'dhuhr': prayerTimesResult.dhuhr,
          'asr': prayerTimesResult.asr,
          'maghrib': prayerTimesResult.maghrib,
          'isha': prayerTimesResult.isha,
        };
      }
    }
  }

  /// Fetch fresh location data from GPS + OSM API
  Future<void> _fetchLocationData() async {
    isUpdatingLocation = true;
    update();

    try {
      debugPrint('=== Début détection GPS ===');
      
      // 1. Get GPS location with timeout
      debugPrint('Demande de position GPS...');
      final position = await locationService.getCurrentLocation();
      
      final lat = position.latitude;
      final lng = position.longitude;
      debugPrint('Position obtenue: $lat, $lng');

      // 2. Get city from OSM API
      debugPrint('Recherche de la ville via OSM...');
      final cityname = await osmService.getCity(lat, lng);
      debugPrint('Ville trouvée: $cityname');

      // 3. Save to Hive for offline use
      await hiveService.saveLocationData(
        latitude: lat,
        longitude: lng,
        city: cityname,
      );

      // 4. Update variables
      city = cityname;

      final prayerTimesResult = prayerService.calculate(
        date: DateTime.now(),
        coordinates: Coordinates(lat, lng),
      );

      if (prayerTimesResult != null) {
        prayerTimes = {
          'fajr': prayerTimesResult.fajr,
          'dhuhr': prayerTimesResult.dhuhr,
          'asr': prayerTimesResult.asr,
          'maghrib': prayerTimesResult.maghrib,
          'isha': prayerTimesResult.isha,
        };
      }

      debugPrint('=== Détection GPS terminée ===');
      update();

      isUpdatingLocation = false;
      update();
    } catch (e) {
      debugPrint('=== Erreur détection GPS: $e ===');
      isUpdatingLocation = false;
      update();
      rethrow;
    }
  }

  /// Use current GPS location to get city
  Future<void> useCurrentLocation() async {
    try {
      isUpdatingLocation = true;
      update();
      debugPrint('=== Début détection GPS ===');

      // Get GPS position with timeout
      debugPrint('Demande de position GPS...');
      final position = await locationService.getCurrentLocation();
      
      final lat = position.latitude;
      final lng = position.longitude;
      debugPrint('Position obtenue: $lat, $lng');

      // Get city from OSM API
      debugPrint('Recherche de la ville via OSM...');
      final cityname = await osmService.getCity(lat, lng);
      debugPrint('Ville trouvée: $cityname');

      // Save to Hive
      await hiveService.saveLocationData(
        latitude: lat,
        longitude: lng,
        city: cityname,
      );

      // Update variables
      city = cityname;

      final prayerTimesResult = prayerService.calculate(
        date: DateTime.now(),
        coordinates: Coordinates(lat, lng),
      );

      if (prayerTimesResult != null) {
        prayerTimes = {
          'fajr': prayerTimesResult.fajr,
          'dhuhr': prayerTimesResult.dhuhr,
          'asr': prayerTimesResult.asr,
          'maghrib': prayerTimesResult.maghrib,
          'isha': prayerTimesResult.isha,
        };
      }

      _updateDates();
      update();

      isUpdatingLocation = false;
      update();

      Get.snackbar(
        'Position actuelle',
        'Ville détectée: $cityname',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isUpdatingLocation = false;
      update();
      debugPrint('=== Erreur détection GPS: $e ===');

      String errorMessage = 'Impossible de récupérer votre position';
      String errorTitle = 'Erreur';

      if (e.toString().contains('services de localisation')) {
        errorTitle = 'GPS désactivé';
        errorMessage = 'Veuillez activer le GPS dans Réglages';
      } else if (e.toString().contains('Permission')) {
        errorTitle = 'Permission requise';
        errorMessage = 'Autorisez l\'accès au GPS dans Réglages > Houda Al Fourquan';
      } else if (e.toString().contains('Délai')) {
        errorTitle = 'Délai dépassé';
        errorMessage = 'Le GPS n\'a pas pu être obtenu. Réessayez.';
      }

      Get.snackbar(
        errorTitle,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => locationService.openAppSettings(),
          child: const Text(
            'Ouvrir Réglages',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  /// Search cities by name
  Future<void> searchCity(String query) async {
    if (query.length < 3) {
      searchResults.clear();
      return;
    }

    isSearching = true;
    searchQuery = query;
    debugPrint('Recherche de ville: $query');

    try {
      final results = await osmService.searchCities(query);
      debugPrint('Résultats trouvés: ${results.length}');
      searchResults = results;
      update();
    } catch (e) {
      debugPrint('Erreur recherche ville: $e');
      searchResults.clear();
      update();
    }

    isSearching = false;
    update();
  }

  /// Select a city from search results
  Future<void> selectCity(Map<String, dynamic> result) async {
    try {
      final lat = double.parse(result['lat']);
      final lon = double.parse(result['lon']);
      final displayName = result['display_name'] as String;
      debugPrint('Ville sélectionnée: $displayName ($lat, $lon)');

      // Extract city name
      final address = result['address'] as Map<String, dynamic>?;
      String cityName =
          address?['city'] ??
          address?['town'] ??
          address?['village'] ??
          address?['county'] ??
          displayName.split(',').first;
      
      debugPrint('Nom de ville extrait: $cityName');

      // Save to Hive
      await hiveService.saveLocationData(
        latitude: lat,
        longitude: lon,
        city: cityName,
      );

      // Update variables IMMEDIATELY
      city = cityName;

      final prayerTimesResult = prayerService.calculate(
        date: DateTime.now(),
        coordinates: Coordinates(lat, lon),
      );

      if (prayerTimesResult != null) {
        prayerTimes = {
          'fajr': prayerTimesResult.fajr,
          'dhuhr': prayerTimesResult.dhuhr,
          'asr': prayerTimesResult.asr,
          'maghrib': prayerTimesResult.maghrib,
          'isha': prayerTimesResult.isha,
        };
      }

      // Clear search
      searchResults.clear();
      searchQuery = '';
      
      // Force update UI with specific ID for CityWidget
      update(['city_update']);
      _updateDates();
      update(['city_update']);

      debugPrint('✅ Ville mise à jour: $cityName');

      // Show confirmation (will appear after dialog closes)
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Ville mise à jour',
          cityName,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      });
    } catch (e) {
      debugPrint('❌ Erreur sélection ville: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner cette ville',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Recalculate prayer times from cached coordinates
  void _recalculatePrayerTimes() {
    final lat = hiveService.getCachedLatitude();
    final lng = hiveService.getCachedLongitude();

    if (lat != null && lng != null) {
      final prayerTimesResult = prayerService.calculate(
        date: DateTime.now(),
        coordinates: Coordinates(lat, lng),
      );

      if (prayerTimesResult != null) {
        prayerTimes = {
          'fajr': prayerTimesResult.fajr,
          'dhuhr': prayerTimesResult.dhuhr,
          'asr': prayerTimesResult.asr,
          'maghrib': prayerTimesResult.maghrib,
          'isha': prayerTimesResult.isha,
        };
        update();
      }
    }
  }

  /// Update Hijri and Gregorian dates
  void _updateDates() {
    // Hijri date
    final hijri = HijriCalendar.now();
    hijriDate = "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}";

    // Gregorian date
    final now = DateTime.now();
    gregorianDate = DateFormat('dd MMM yyyy').format(now);
    update();
  }

  /// Public update dates for widget access
  void updateDatesPublic() => _updateDates();

  /// Manual refresh of location (calls GPS + OSM API)
  Future<void> refreshLocation() async {
    await _fetchLocationData();
    _updateDates();
    Get.snackbar(
      'Location Updated',
      'City has been refreshed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Start countdown timer to next prayer
  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  /// Update countdown display
  void _updateCountdown() {
    if (prayerTimes.isEmpty) return;

    final now = DateTime.now();
    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes['fajr']},
      {'name': 'Dhuhr', 'time': prayerTimes['dhuhr']},
      {'name': 'Asr', 'time': prayerTimes['asr']},
      {'name': 'Maghrib', 'time': prayerTimes['maghrib']},
      {'name': 'Isha', 'time': prayerTimes['isha']},
    ];

    String? nextPrayer;
    DateTime? nextTime;

    for (var prayer in prayers) {
      final time = prayer['time'] as DateTime?;
      if (time != null && time.isAfter(now)) {
        nextPrayer = prayer['name'] as String;
        nextTime = time;
        break;
      }
    }

    // If no prayer found today, next is Fajr tomorrow
    if (nextPrayer == null) {
      nextPrayer = 'Fajr';
      nextTime = prayerTimes['fajr']?.add(const Duration(days: 1));
    }

    nextPrayerName = nextPrayer;

    if (nextTime != null) {
      final difference = nextTime.difference(now);
      final hours = difference.inHours.toString().padLeft(2, '0');
      final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
      countdown = '$hours:$minutes:$seconds';
    }
    update();
  }

  /// Check if cache should be refreshed (older than 24 hours)
  bool shouldRefreshCache() {
    return hiveService.isCacheExpired(const Duration(hours: 24));
  }

  /// Get cache age in hours
  String getCacheAge() {
    final hours = hiveService.getCacheAgeInHours();
    if (hours == double.infinity) return 'No cache';
    if (hours < 1) return '< 1 hour';
    return '${hours.toInt()}h';
  }
}
