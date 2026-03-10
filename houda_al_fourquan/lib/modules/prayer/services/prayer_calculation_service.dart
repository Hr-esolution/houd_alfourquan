import 'package:flutter/foundation.dart';
import 'package:adhan_dart/adhan_dart.dart';

/// Prayer Calculation Service using adhan_dart
/// Handles all prayer time calculations offline
class PrayerCalculationService {
  /// Cache for calculated prayer times
  final Map<String, PrayerTimes> _cache = {};

  /// Available calculation methods
  static final Map<String, CalculationParameters Function()> calculationMethods = {
    'MWL': CalculationMethodParameters.muslimWorldLeague,
    'Makkah': CalculationMethodParameters.ummAlQura,
    'Egypt': CalculationMethodParameters.egyptian,
    'Karachi': CalculationMethodParameters.karachi,
    'UmmAlQura': CalculationMethodParameters.ummAlQura,
    'Dubai': CalculationMethodParameters.dubai,
    'MoonsightingCommittee': CalculationMethodParameters.moonsightingCommittee,
    'Kuwait': CalculationMethodParameters.kuwait,
    'Qatar': CalculationMethodParameters.qatar,
    'Singapore': CalculationMethodParameters.singapore,
    'Tehran': CalculationMethodParameters.tehran,
    'Turkey': CalculationMethodParameters.turkiye,
    'NorthAmerica': CalculationMethodParameters.northAmerica,
  };

  /// Default method
  static const String defaultMethod = 'MWL';

  /// Calculate prayer times for given date and coordinates
  ///
  /// [date] - The date for which to calculate prayer times
  /// [coordinates] - Latitude and longitude
  /// [method] - Calculation method name (e.g., 'MWL', 'Makkah')
  ///
  /// Returns [PrayerTimes] object or null if calculation fails
  PrayerTimes? calculate({
    required DateTime date,
    required Coordinates coordinates,
    String method = defaultMethod,
  }) {
    try {
      // Create cache key
      final cacheKey = _createCacheKey(date, coordinates, method);

      // Check cache first
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey];
      }

      // Get calculation method
      final calculationMethodFunc =
          calculationMethods[method] ?? CalculationMethodParameters.muslimWorldLeague;
      final calculationParameters = calculationMethodFunc();

      // Calculate prayer times
      final prayerTimes = PrayerTimes(
        date: date,
        coordinates: coordinates,
        calculationParameters: calculationParameters,
      );

      // Cache the result
      _cache[cacheKey] = prayerTimes;

      return prayerTimes;
    } catch (e) {
      debugPrint('Error calculating prayer times: $e');
      return null;
    }
  }

  /// Get current prayer from prayer times
  ///
  /// Returns the current prayer or null if no prayer is active
  Prayer? getCurrentPrayer(PrayerTimes prayerTimes, {DateTime? date}) {
    return prayerTimes.currentPrayer(date: date ?? DateTime.now());
  }

  /// Get next prayer from prayer times
  ///
  /// Returns the next prayer or null if no more prayers today
  Prayer? getNextPrayer(PrayerTimes prayerTimes, {DateTime? date}) {
    return prayerTimes.nextPrayer(date: date ?? DateTime.now());
  }

  /// Get time for specific prayer
  ///
  /// Returns the time for the given prayer or null if invalid
  DateTime? getPrayerTime(PrayerTimes prayerTimes, Prayer prayer) {
    return prayerTimes.timeForPrayer(prayer);
  }

  /// Get time remaining until next prayer
  ///
  /// Returns duration until next prayer
  Duration getTimeUntilNextPrayer(PrayerTimes prayerTimes) {
    final nextPrayer = getNextPrayer(prayerTimes);
    if (nextPrayer == null) {
      return Duration.zero;
    }

    final now = DateTime.now();
    final nextPrayerTime = getPrayerTime(prayerTimes, nextPrayer);

    if (nextPrayerTime == null) {
      return Duration.zero;
    }

    // Handle case where next prayer is tomorrow
    if (nextPrayerTime.isBefore(now)) {
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final tomorrowPrayerTimes = calculate(
        date: tomorrow,
        coordinates: prayerTimes.coordinates,
      );

      if (tomorrowPrayerTimes != null) {
        final tomorrowPrayerTime = getPrayerTime(
          tomorrowPrayerTimes,
          nextPrayer,
        );
        if (tomorrowPrayerTime != null) {
          return tomorrowPrayerTime.difference(now);
        }
      }
      return Duration.zero;
    }

    return nextPrayerTime.difference(now);
  }

  /// Get Qibla direction in degrees from North
  ///
  /// Returns the Qibla direction in degrees (0-360)
  double getQiblaDirection(Coordinates coordinates) {
    return Qibla.qibla(coordinates);
  }

  /// Format prayer name for display
  ///
  /// Returns localized prayer name
  String formatPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return prayer.name;
    }
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }

  /// Create cache key from parameters
  String _createCacheKey(
    DateTime date,
    Coordinates coordinates,
    String method,
  ) {
    return '${date.year}-${date.month}-${date.day}_${coordinates.latitude}_${coordinates.longitude}_$method';
  }

  /// Get prayer times for specific date with automatic DST handling
  PrayerTimes? calculateWithDST({
    required DateTime date,
    required Coordinates coordinates,
    String method = defaultMethod,
  }) {
    // adhan_dart handles DST automatically based on system timezone
    // This method is provided for future enhancements
    return calculate(date: date, coordinates: coordinates, method: method);
  }
}
