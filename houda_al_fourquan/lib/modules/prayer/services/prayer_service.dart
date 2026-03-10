import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:adhan_dart/adhan_dart.dart';

/// Prayer Service using adhan_dart and OSM Nominatim
class PrayerService {
  // OSM Nominatim API
  static const String _osmBaseUrl = 'https://nominatim.openstreetmap.org';

  // Cache for location
  Coordinates? _cachedCoordinates;
  String? _cachedCity;

  /// Get coordinates from city name using OSM Nominatim
  Future<Coordinates?> getCoordinatesFromCity(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$_osmBaseUrl/search?q=$cityName&format=json&limit=1'),
        headers: {'User-Agent': 'HoudaAlFourquan/1.0 (mindcom2018@gmail.com)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        if (data.isNotEmpty) {
          final location = data[0] as Map<String, dynamic>;
          final lat = double.parse(location['lat']);
          final lon = double.parse(location['lon']);

          _cachedCoordinates = Coordinates(lat, lon);
          _cachedCity = cityName;

          return _cachedCoordinates;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }

  /// Get current location from IP (fallback method)
  Future<Coordinates?> getCurrentLocationFromIP() async {
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lat = data['latitude'] as double;
        final lon = data['longitude'] as double;
        final city = data['city'] as String?;

        _cachedCoordinates = Coordinates(lat, lon);
        _cachedCity = city;

        return _cachedCoordinates;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting location from IP: $e');
      return null;
    }
  }

  /// Calculate prayer times for given date and coordinates
  PrayerTimes calculatePrayerTimes({
    required DateTime date,
    required Coordinates coordinates,
    CalculationParameters? params,
  }) {
    final calculationParams = params ?? CalculationMethodParameters.karachi();

    return PrayerTimes(
      date: date,
      coordinates: coordinates,
      calculationParameters: calculationParams,
    );
  }

  /// Get prayer times for today
  Future<PrayerTimes?> getTodayPrayerTimes({
    Coordinates? coordinates,
    CalculationParameters? params,
  }) async {
    try {
      final coords = coordinates ?? await _getCoordinates();
      if (coords == null) return null;

      return calculatePrayerTimes(
        date: DateTime.now(),
        coordinates: coords,
        params: params,
      );
    } catch (e) {
      debugPrint('Error getting prayer times: $e');
      return null;
    }
  }

  /// Get Qibla direction
  double getQiblaDirection(Coordinates coordinates) {
    return Qibla.qibla(coordinates);
  }

  /// Get next prayer time
  Prayer? getNextPrayer(PrayerTimes prayerTimes, {DateTime? date}) {
    return prayerTimes.nextPrayer(date: date ?? DateTime.now());
  }

  /// Get time remaining until next prayer
  Duration getTimeUntilNextPrayer(PrayerTimes prayerTimes) {
    final nextPrayer = getNextPrayer(prayerTimes);
    if (nextPrayer == null) return Duration.zero;
    final now = DateTime.now();
    final nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);

    return nextPrayerTime.difference(now);
  }

  /// Get current prayer
  Prayer? getCurrentPrayer(PrayerTimes prayerTimes, {DateTime? date}) {
    return prayerTimes.currentPrayer(date: date ?? DateTime.now());
  }

  /// Helper to get coordinates
  Future<Coordinates?> _getCoordinates() async {
    if (_cachedCoordinates != null) {
      return _cachedCoordinates;
    }

    // Try IP-based location as fallback
    return await getCurrentLocationFromIP();
  }

  /// Get cached city
  String? getCachedCity() => _cachedCity;

  /// Clear cache
  void clearCache() {
    _cachedCoordinates = null;
    _cachedCity = null;
  }
}
