import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:http/http.dart' as http;

/// Unified Location Service
///
/// Handles GPS permissions, location retrieval, and city detection
/// for prayer times calculation and Qibla direction.
///
/// Features:
/// - Automatic permission handling with settings guidance
/// - Location caching (5 minutes)
/// - City detection via OSM Nominatim (no storage)
/// - Fallback to manual city selection
/// - Works on first install
class LocationService {
  Position? _cachedPosition;
  DateTime? _cacheTimestamp;
  String? _cachedCity;

  /// Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Default coordinates (Makkah)
  static const Coordinates defaultCoordinates = Coordinates(21.4225, 39.8262);
  static const String defaultCity = 'Makkah';

  // ==================== PERMISSION HANDLING ====================

  /// Check if location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check if permission is granted (whileInUse or always)
  Future<bool> hasPermission() async {
    final permission = await checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Open app settings for manual permission grant
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // ==================== LOCATION RETRIEVAL ====================

  /// Get current location with automatic permission handling
  ///
  /// Returns [Coordinates] for adhan_dart or null if failed
  Future<Coordinates?> getCurrentLocation({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Check if cached location is still valid
      if (_cachedPosition != null && _cacheTimestamp != null) {
        if (DateTime.now().difference(_cacheTimestamp!) < _cacheDuration) {
          debugPrint('📍 Using cached location');
          return _toCoordinates(_cachedPosition!);
        }
      }

      // 1. Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location service disabled');
        throw LocationException(
          'GPS désactivé',
          'Veuillez activer la localisation dans les paramètres.',
          action: LocationAction.openSettings,
        );
      }

      // 2. Check and request permission
      LocationPermission permission = await checkPermission();
      debugPrint('🔐 Permission actuelle: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('📋 Demande de permission...');
        permission = await requestPermission();
        debugPrint('🔐 Permission après demande: $permission');

        if (permission == LocationPermission.denied) {
          throw LocationException(
            'Permission refusée',
            'Autorisez l\'accès à la localisation pour calculer les horaires de prière.',
            action: LocationAction.openAppSettings,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException(
          'Permission refusée définitivement',
          'Activez la localisation dans Réglages > Houda Al Fourquan > Localisation.',
          action: LocationAction.openAppSettings,
        );
      }

      // 3. Get current position with high accuracy
      debugPrint('🛰️ Récupération de la position GPS...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
      debugPrint('✅ Position obtenue: ${position.latitude}, ${position.longitude}');

      // 4. Cache the position
      _cachedPosition = position;
      _cacheTimestamp = DateTime.now();

      return _toCoordinates(position);
    } on TimeoutException {
      throw LocationException(
        'Délai dépassé',
        'Le GPS met trop de temps à répondre. Essayez à nouveau ou sélectionnez une ville manuellement.',
        action: LocationAction.manualSelection,
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      debugPrint('❌ Erreur de localisation: $e');
      throw LocationException(
        'Erreur de localisation',
        'Impossible d\'obtenir votre position. ${e.toString()}',
        action: LocationAction.manualSelection,
      );
    }
  }

  /// Get last known location (faster but may be outdated)
  Future<Coordinates?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        debugPrint('📍 Last known: ${position.latitude}, ${position.longitude}');
        _cachedPosition = position;
        _cacheTimestamp = DateTime.now();
        return _toCoordinates(position);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Last known location error: $e');
      return null;
    }
  }

  /// Get location with smart fallback strategy
  ///
  /// Strategy:
  /// 1. Try cached location
  /// 2. Try last known location
  /// 3. Try current GPS location
  /// 4. Return default (Makkah) if all fail
  Future<CoordinatesResult> getLocationWithFallback() async {
    // Try cache first
    if (_cachedPosition != null) {
      try {
        final coords = await getCurrentLocation();
        if (coords != null) {
          final city = _cachedCity ?? await getCityFromCoords(coords);
          return CoordinatesResult(
            coordinates: coords,
            cityName: city,
            isDefault: false,
            isCached: true,
          );
        }
      } catch (_) {}
    }

    // Try last known
    try {
      final lastKnown = await getLastKnownLocation();
      if (lastKnown != null) {
        final city = await getCityFromCoords(lastKnown);
        return CoordinatesResult(
          coordinates: lastKnown,
          cityName: city,
          isDefault: false,
          isCached: false,
        );
      }
    } catch (_) {}

    // Try GPS with shorter timeout
    try {
      final current = await getCurrentLocation(
        timeout: const Duration(seconds: 15),
      );
      if (current != null) {
        final city = await getCityFromCoords(current);
        return CoordinatesResult(
          coordinates: current,
          cityName: city,
          isDefault: false,
          isCached: false,
        );
      }
    } catch (_) {}

    // Fallback to Makkah
    debugPrint('⚠️ Using default location: Makkah');
    return CoordinatesResult(
      coordinates: defaultCoordinates,
      cityName: defaultCity,
      isDefault: true,
      isCached: false,
    );
  }

  // ==================== CITY DETECTION ====================

  /// Get city name from coordinates using OSM Nominatim API
  ///
  /// Only extracts city name for display - no storage
  Future<String> getCityFromCoords(Coordinates coords) async {
    // Check cache
    if (_cachedCity != null && _cachedPosition != null) {
      if (_cachedPosition!.latitude == coords.latitude &&
          _cachedPosition!.longitude == coords.longitude) {
        debugPrint('🏙️ Using cached city: $_cachedCity');
        return _cachedCity!;
      }
    }

    try {
      debugPrint('🔍 Searching city for: ${coords.latitude}, ${coords.longitude}');

      final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse').replace(
        queryParameters: {
          'format': 'json',
          'lat': coords.latitude.toString(),
          'lon': coords.longitude.toString(),
          'zoom': '12',
          'addressdetails': '1',
          'accept-language': 'fr',
        },
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'HoudaAlFourquan/1.0 (mindcom2018@gmail.com)'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final city = address['city'] as String?;
          final municipality = address['municipality'] as String?;
          final town = address['town'] as String?;
          final village = address['village'] as String?;
          final suburb = address['suburb'] as String?;
          final county = address['county'] as String?;
          final country = address['country'] as String?;

          // Prioritize city types
          String cityName = city ??
              municipality ??
              town ??
              village ??
              suburb ??
              county ??
              'Position actuelle';

          // Special handling for Morocco
          if (country == 'Maroc' || country == 'Morocco') {
            if (cityName == 'Casablanca') {
              // Verify if really close to Casablanca
              final distance = _calculateDistance(
                coords.latitude,
                coords.longitude,
                33.5731,
                -7.5898,
              );
              if (distance > 50) {
                cityName = suburb ?? town ?? village ?? 'Maroc';
              }
            }
            cityName = cityName == 'Unknown' ? 'Maroc' : cityName;
          }

          debugPrint('✅ City found: $cityName');
          _cachedCity = cityName;
          return cityName;
        }
      }

      debugPrint('⚠️ No city found, using default');
      return 'Position actuelle';
    } catch (e) {
      debugPrint('❌ City detection error: $e');
      return 'Position actuelle';
    }
  }

  /// Search for cities by name - worldwide search
  Future<List<CitySearchResult>> searchCities(String query) async {
    if (query.length < 2) return [];

    try {
      debugPrint('🔍 Searching cities: $query');

      final uri = Uri.parse('https://nominatim.openstreetmap.org/search').replace(
        queryParameters: {
          'format': 'json',
          'q': query,
          'limit': '20',
          'addressdetails': '1',
          'countrycodes': 'ma,dz,tn,ly,mr', // Prioritize Morocco + Arab countries
        },
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'HoudaAlFourquan/1.0 (mindcom2018@gmail.com)'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

        final results = data
            .where((item) {
              final type = item['type'] as String?;
              final address = item['address'] as Map<String, dynamic>?;
              final city = address?['city'] ??
                  address?['town'] ??
                  address?['village'] ??
                  address?['municipality'];

              final isCityType = type == 'city' ||
                  type == 'town' ||
                  type == 'village' ||
                  type == 'municipality';

              return isCityType && city != null;
            })
            .take(20)
            .map((item) {
              final address = item['address'] as Map<String, dynamic>;
              return CitySearchResult(
                name: address['city'] ??
                    address['town'] ??
                    address['village'] ??
                    'Unknown',
                displayName: item['display_name'] as String,
                latitude: double.parse(item['lat']),
                longitude: double.parse(item['lon']),
                country: address['country'] as String? ?? 'Unknown',
              );
            })
            .toList();

        debugPrint('✅ Found ${results.length} cities');
        return results;
      }

      return [];
    } catch (e) {
      debugPrint('❌ City search error: $e');
      return [];
    }
  }

  // ==================== UTILITIES ====================

  /// Convert Geolocator Position to adhan_dart Coordinates
  Coordinates _toCoordinates(Position position) {
    return Coordinates(position.latitude, position.longitude);
  }

  /// Calculate distance between two points in km (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat) * math.sin(dLat) +
        (_toRadians(lat1) * _toRadians(lat2)) *
            math.sin(dLon) * math.sin(dLon);

    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  /// Clear cached location and city
  void clearCache() {
    _cachedPosition = null;
    _cacheTimestamp = null;
    _cachedCity = null;
    debugPrint('🗑️ Location cache cleared');
  }

  /// Set manual location
  void setManualLocation(Coordinates coords, String cityName) {
    _cachedPosition = Position(
      latitude: coords.latitude,
      longitude: coords.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    _cacheTimestamp = DateTime.now();
    _cachedCity = cityName;
    debugPrint('📍 Manual location set: $cityName (${coords.latitude}, ${coords.longitude})');
  }
}

// ==================== RESULT CLASSES ====================

/// Result of location detection with city name
class CoordinatesResult {
  final Coordinates coordinates;
  final String cityName;
  final bool isDefault;
  final bool isCached;

  CoordinatesResult({
    required this.coordinates,
    required this.cityName,
    required this.isDefault,
    required this.isCached,
  });

  @override
  String toString() {
    return 'CoordinatesResult(city: $cityName, coords: ${coordinates.latitude}, ${coordinates.longitude}, default: $isDefault, cached: $isCached)';
  }
}

/// City search result
class CitySearchResult {
  final String name;
  final String displayName;
  final double latitude;
  final double longitude;
  final String country;

  CitySearchResult({
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.country,
  });

  Coordinates get coordinates => Coordinates(latitude, longitude);

  @override
  String toString() {
    return 'CitySearchResult(name: $name, country: $country)';
  }
}

/// Custom exception for location errors
class LocationException implements Exception {
  final String title;
  final String message;
  final LocationAction action;

  LocationException(this.title, this.message, {this.action = LocationAction.none});

  @override
  String toString() => 'LocationException: $title - $message';
}

/// Action to take when location error occurs
enum LocationAction {
  none,
  openAppSettings,
  openSettings,
  manualSelection,
}
