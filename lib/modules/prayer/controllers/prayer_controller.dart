import 'dart:async';
import 'package:get/get.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart' show LocationPermission;
import '../services/prayer_calculation_service.dart';
import '../services/location_service.dart';
import '../models/prayer_time_model.dart';

/// Prayer Controller using GetBuilder (NO Obx/Rx)
///
/// Manages prayer times calculation, location, and countdown
class PrayerController extends GetxController {
  late PrayerCalculationService _calculationService;
  late LocationService _locationService;

  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _permissionDenied = false;

  // Location
  Coordinates? _coordinates;
  String _cityName = 'Loading...';
  String _selectedMethod = PrayerCalculationService.defaultMethod;

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
  bool get permissionDenied => _permissionDenied;
  String get cityName => _cityName;
  String get selectedMethod => _selectedMethod;
  PrayerTimes? get prayerTimes => _prayerTimes;
  List<PrayerTimeModel> get todayPrayers => _todayPrayers;
  Prayer? get nextPrayer => _nextPrayer;
  Prayer? get currentPrayer => _currentPrayer;
  Duration get timeUntilNext => _timeUntilNext;

  @override
  void onInit() {
    super.onInit();
    _calculationService = PrayerCalculationService();
    _locationService = LocationService();
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
      _permissionDenied = false;
      update();

      // Get location
      final coordinates = await _locationService.getLocationWithFallback();

      _coordinates = coordinates;

      // Get city name
      _cityName =
          await _locationService.getCityName(coordinates) ?? 'Current Location';

      // Calculate prayer times
      _prayerTimes = _calculationService.calculate(
        date: _prayerDate,
        coordinates: coordinates,
        method: _selectedMethod,
      );

      if (_prayerTimes == null) {
        throw Exception('Failed to calculate prayer times');
      }

      // Build prayer list
      _buildPrayerList();

      // Update next prayer
      _updateNextPrayer();

      _isLoading = false;
      update();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();

      // Check if it's a permission error
      if (_errorMessage.contains('permission')) {
        _permissionDenied = true;
      }

      update();

      Get.snackbar(
        'Error',
        'Failed to load prayer times: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
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
      _timeUntilNext = _calculationService.getTimeUntilNextPrayer(_prayerTimes!);
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

      // Here you would integrate with a geocoding service
      // For now, just update the name
      _cityName = cityName;

      await loadPrayerTimes();
    } catch (e) {
      _isLoading = false;
      update();

      Get.snackbar(
        'Error',
        'City not found: $cityName',
        snackPosition: SnackPosition.BOTTOM,
      );
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
    await loadPrayerTimes();
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
}
