import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart';

/// Location Service using Geolocator
/// Handles GPS permissions and location retrieval
class LocationService {
  Position? _cachedPosition;
  DateTime? _cacheTimestamp;

  /// Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location with automatic permission handling
  ///
  /// Returns [Coordinates] for adhan_dart or null if failed
  Future<Coordinates?> getCurrentLocation() async {
    try {
      // Check if cached location is still valid
      if (_cachedPosition != null && _cacheTimestamp != null) {
        if (DateTime.now().difference(_cacheTimestamp!) < _cacheDuration) {
          return _toCoordinates(_cachedPosition!);
        }
      }

      // Check permission
      LocationPermission permission = await checkPermission();

      // Request permission if not granted
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();

        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      // Cache the position
      _cachedPosition = position;
      _cacheTimestamp = DateTime.now();

      return _toCoordinates(position);
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Get last known location (faster but may be outdated)
  Future<Coordinates?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _cachedPosition = position;
        _cacheTimestamp = DateTime.now();
        return _toCoordinates(position);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting last known location: $e');
      return null;
    }
  }

  /// Get location with fallback strategy
  ///
  /// Strategy:
  /// 1. Try cached location
  /// 2. Try last known location
  /// 3. Try current GPS location
  /// 4. Return default (Makkah) if all fail
  Future<Coordinates> getLocationWithFallback() async {
    // Try cache first
    if (_cachedPosition != null) {
      final coords = await getCurrentLocation();
      if (coords != null) return coords;
    }

    // Try last known
    final lastKnown = await getLastKnownLocation();
    if (lastKnown != null) return lastKnown;

    // Try GPS
    final current = await getCurrentLocation();
    if (current != null) return current;

    // Fallback to Makkah
    debugPrint('Using default location: Makkah');
    return Coordinates(21.4225, 39.8262);
  }

  /// Convert Geolocator Position to adhan_dart Coordinates
  Coordinates _toCoordinates(Position position) {
    return Coordinates(position.latitude, position.longitude);
  }

  /// Clear cached location
  void clearCache() {
    _cachedPosition = null;
    _cacheTimestamp = null;
  }

  /// Get city name from coordinates (reverse geocoding)
  /// Note: Requires geocoding package for full functionality
  Future<String?> getCityName(Coordinates coordinates) async {
    // For now, return a placeholder since geocoding requires additional package
    // In production, add geocoding package or use OSM Nominatim API
    return 'Current Location';
  }
}
