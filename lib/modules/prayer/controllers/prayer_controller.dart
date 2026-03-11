import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart' show LocationPermission;
import '../services/prayer_calculation_service.dart';
import '../../../core/services/location_service.dart';
import '../models/prayer_time_model.dart';
import '../services/adhan_notification_service.dart';
import '../../../core/widgets/city_selection_dialog.dart';

/// Prayer Controller using GetBuilder (NO Obx/Rx)
///
/// Manages prayer times calculation, location, and countdown
class PrayerController extends GetxController {
  late PrayerCalculationService _calculationService;
  final LocationService _locationService = LocationService();

  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  LocationException? _locationException;

  // Location
  Coordinates? _coordinates;
  String _cityName = 'Chargement...';
  String _selectedMethod = PrayerCalculationService.defaultMethod;
  bool _isDefaultLocation = false;

  // Prayer times
  PrayerTimes? _prayerTimes;
  List<PrayerTimeModel> _todayPrayers = [];
  final DateTime _prayerDate = DateTime.now();

  // Next prayer info
  Prayer? _nextPrayer;
  Prayer? _currentPrayer;
  Duration _timeUntilNext = Duration.zero;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  LocationException? get locationException => _locationException;
  String get cityName => _cityName;
  String get selectedMethod => _selectedMethod;
  PrayerTimes? get prayerTimes => _prayerTimes;
  List<PrayerTimeModel> get todayPrayers => _todayPrayers;
  Prayer? get nextPrayer => _nextPrayer;
  Prayer? get currentPrayer => _currentPrayer;
  Duration get timeUntilNext => _timeUntilNext;
  bool get isDefaultLocation => _isDefaultLocation;
  Coordinates? get coordinates => _coordinates;

  @override
  void onInit() {
    super.onInit();
    _calculationService = PrayerCalculationService();
    loadPrayerTimes();

    // Update countdown every second
    Timer.periodic(const Duration(seconds: 1), (_) {
      if (_prayerTimes != null) {
        _updateNextPrayer();
        update();
      }
    });
  }

  /// Load prayer times with automatic location detection
  Future<void> loadPrayerTimes() async {
    try {
      _isLoading = true;
      _hasError = false;
      _locationException = null;
      update();

      // Get location with fallback strategy
      final result = await _locationService.getLocationWithFallback();

      _coordinates = result.coordinates;
      _cityName = result.cityName;
      _isDefaultLocation = result.isDefault;

      debugPrint('📍 Location: ${result.cityName} (${result.coordinates.latitude}, ${result.coordinates.longitude})');

      // Calculate prayer times
      _prayerTimes = _calculationService.calculate(
        date: _prayerDate,
        coordinates: result.coordinates,
        method: _selectedMethod,
      );

      if (_prayerTimes == null) {
        throw Exception('Échec du calcul des horaires de prière');
      }

      // Build prayer list
      _buildPrayerList();

      // Update next prayer
      _updateNextPrayer();

      // Schedule Adhan notifications
      _scheduleAdhanNotifications();

      _isLoading = false;

      // Show warning if using default location
      if (result.isDefault) {
        Get.rawSnackbar(
          message: 'Utilisation de Makkah par défaut. Appuyez pour sélectionner votre ville.',
          title: 'Position non détectée',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange,
          onTap: (_) => selectCityManually(),
        );
      }

      update();
    } on LocationException catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.message;
      _locationException = e;
      update();

      debugPrint('❌ Location error: ${e.title} - ${e.message}');
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
      update();

      debugPrint('❌ Unexpected error: $e');
    }
  }

  /// Build prayer list from PrayerTimes
  void _buildPrayerList() {
    if (_prayerTimes == null) return;

    _todayPrayers = [
      PrayerTimeModel(
        name: 'Fajr',
        time: _prayerTimes!.fajr,
        prayer: Prayer.fajr,
      ),
      PrayerTimeModel(
        name: 'Sunrise',
        time: _prayerTimes!.sunrise,
        prayer: Prayer.sunrise,
      ),
      PrayerTimeModel(
        name: 'Dhuhr',
        time: _prayerTimes!.dhuhr,
        prayer: Prayer.dhuhr,
      ),
      PrayerTimeModel(name: 'Asr', time: _prayerTimes!.asr, prayer: Prayer.asr),
      PrayerTimeModel(
        name: 'Maghrib',
        time: _prayerTimes!.maghrib,
        prayer: Prayer.maghrib,
      ),
      PrayerTimeModel(
        name: 'Isha',
        time: _prayerTimes!.isha,
        prayer: Prayer.isha,
      ),
    ];

    // Mark current and next prayers
    _markCurrentAndNextPrayers();
  }

  /// Mark current and next prayers in the list
  void _markCurrentAndNextPrayers() {
    _todayPrayers = _todayPrayers.map((prayer) {
      return PrayerTimeModel(
        name: prayer.name,
        time: prayer.time,
        prayer: prayer.prayer,
        isNext: prayer.prayer == _nextPrayer,
        isCurrent: prayer.prayer == _currentPrayer,
      );
    }).toList();
  }

  /// Update next prayer information
  void _updateNextPrayer() {
    if (_prayerTimes != null) {
      _nextPrayer = _calculationService.getNextPrayer(_prayerTimes!);
      _timeUntilNext = _calculationService.getTimeUntilNextPrayer(
        _prayerTimes!,
      );
      _currentPrayer = _calculationService.getCurrentPrayer(_prayerTimes!);
    }
  }

  /// Change calculation method
  void setCalculationMethod(String method) {
    if (PrayerCalculationService.calculationMethods.containsKey(method)) {
      _selectedMethod = method;
      // Clear cache and recalculate
      _calculationService.clearCache();
      loadPrayerTimes();
    }
  }

  /// Set custom location by city name
  Future<void> setCity(String cityName) async {
    try {
      _isLoading = true;
      update();

      _cityName = cityName;

      await loadPrayerTimes();
    } catch (e) {
      _isLoading = false;
      update();

      Get.snackbar(
        'Erreur',
        'Ville introuvable: $cityName',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Select city manually via dialog
  Future<void> selectCityManually() async {
    try {
      final result = await showCitySelectionDialog(Get.context!);

      if (result != null) {
        _isLoading = true;
        update();

        // Set manual location
        _locationService.setManualLocation(result.coordinates, result.name);

        await loadPrayerTimes();

        Get.snackbar(
          'Ville mise à jour',
          '${result.name}, ${result.country}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('❌ City selection error: $e');
    }
  }

  /// Get Qibla direction
  double getQiblaDirection() {
    if (_coordinates == null) return 0;
    return _calculationService.getQiblaDirection(_coordinates!);
  }

  /// Get formatted time until next prayer
  String getTimeUntilNextFormatted() {
    final hours = _timeUntilNext.inHours;
    final minutes = _timeUntilNext.inMinutes.remainder(60);
    final seconds = _timeUntilNext.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Get next prayer name
  String getNextPrayerName() {
    if (_nextPrayer == null) return 'Fajr';
    return _calculationService.formatPrayerName(_nextPrayer!);
  }

  /// Refresh location and recalculate
  Future<void> refreshLocation() async {
    _locationService.clearCache();
    Get.snackbar(
      'Actualisation',
      'Recherche de votre position...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    await loadPrayerTimes();
  }

  /// Handle location error and show appropriate action
  Future<void> handleLocationError() async {
    if (_locationException == null) return;

    final action = _locationException!.action;

    switch (action) {
      case LocationAction.openAppSettings:
        await _locationService.openAppSettings();
        break;
      case LocationAction.openSettings:
        await _locationService.openLocationSettings();
        break;
      case LocationAction.manualSelection:
        await selectCityManually();
        break;
      case LocationAction.none:
        // Just show error
        break;
    }
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    final permission = await _locationService.requestPermission();
    final isGranted =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    if (isGranted) {
      await loadPrayerTimes();
    }

    return isGranted;
  }

  /// Get available calculation methods
  List<String> getAvailableMethods() {
    return PrayerCalculationService.calculationMethods.keys.toList();
  }

  /// Schedule Adhan notifications for all prayers
  void _scheduleAdhanNotifications() {
    if (_prayerTimes == null) return;

    try {
      final adhanService = Get.find<AdhanNotificationService>();

      // Create prayer times map
      final prayerTimesMap = <String, DateTime>{
        'fajr': _prayerTimes!.fajr,
        'dhuhr': _prayerTimes!.dhuhr,
        'asr': _prayerTimes!.asr,
        'maghrib': _prayerTimes!.maghrib,
        'isha': _prayerTimes!.isha,
      };

      // Schedule notifications
      adhanService.rescheduleAllNotifications(prayerTimesMap);

      debugPrint('📅 Adhan notifications scheduled for all prayers');
    } catch (e) {
      debugPrint('❌ Error scheduling Adhan notifications: $e');
    }
  }
}
