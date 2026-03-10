import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  /// Get current location with proper permission handling
  Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
          'Les services de localisation sont désactivés.\nVeuillez activer le GPS dans Réglages > Confidentialité > Service de localisation.',
        );
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Permission actuelle: $permission');

      // Request permission if not granted
      if (permission == LocationPermission.denied) {
        debugPrint('Demande de permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('Permission après demande: $permission');

        if (permission == LocationPermission.denied) {
          throw Exception(
            'Permission de localisation refusée.\nVeuillez autoriser l\'accès dans Réglages > Houda Al Fourquan > Localisation.',
          );
        }
      }

      // Check for permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permission de localisation refusée définitivement.\nVeuillez activer la localisation dans Réglages > Houda Al Fourquan > Localisation.',
        );
      }

      // Get current position with high accuracy
      debugPrint('Récupération de la position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 30),
        ),
      );
      debugPrint(
        'Position obtenue: ${position.latitude}, ${position.longitude}',
      );

      return position;
    } on TimeoutException {
      throw Exception(
        'Délai d\'attente dépassé.\nAssurez-vous que le GPS est activé et que vous êtes à l\'extérieur.',
      );
    } catch (e) {
      debugPrint('Erreur de localisation: $e');
      if (e.toString().contains('Permission')) {
        rethrow;
      }
      throw Exception(
        'Erreur de localisation: ${e.toString()}\nVérifiez que le GPS est activé.',
      );
    }
  }

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Open app settings for permission
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
