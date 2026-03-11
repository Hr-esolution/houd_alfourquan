import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/location_service.dart';
import '../../core/widgets/city_selection_dialog.dart';

class QiblaController extends GetxController {
  // Coordonnées de La Mecque
  static const double meccaLat = 21.4225;
  static const double meccaLng = 39.8262;

  // Services
  final LocationService _locationService = LocationService();

  // Localisation
  double userLat = 0.0;
  double userLng = 0.0;
  String cityName = 'Localisation...';

  // Boussole
  double compassHeading = 0.0;
  double qiblaAngle = 0.0;
  double needleAngle = 0.0;

  // Infos calculées
  double distanceToMeccaKm = 0.0;

  // État
  bool isCompassAvailable = false;
  bool isLoading = true;
  String errorMessage = '';
  LocationException? _locationException;
  bool useCompassMode = true; // true = compass, false = diagram

  // Recherche de ville
  bool isSearchingCity = false;
  List<CitySearchResult> searchResults = [];
  String searchQuery = '';

  StreamSubscription? _qiblahSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeQibla();
  }

  Future<void> _initializeQibla() async {
    try {
      // 1. Load location
      await _loadLocation();

      // 2. Calculate Qibla angle and distance
      _calculateQibla();

      // 3. Start compass listening
      await _startCompass();

      isLoading = false;
      update();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      update();
    }
  }

  Future<void> _loadLocation() async {
    try {
      // Get location with fallback strategy
      final result = await _locationService.getLocationWithFallback();

      userLat = result.coordinates.latitude;
      userLng = result.coordinates.longitude;
      cityName = result.cityName;

      debugPrint('📍 Location: $cityName ($userLat, $userLng)');

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
    } on LocationException catch (e) {
      debugPrint('❌ Location error: ${e.title} - ${e.message}');
      _locationException = e;
      errorMessage = e.message;

      // Use Paris as fallback for display
      userLat = 48.8566;
      userLng = 2.3522;
      cityName = 'Paris (défaut)';
    } catch (e) {
      debugPrint('❌ Location error: $e');
      errorMessage = 'Position indisponible';
      userLat = 48.8566;
      userLng = 2.3522;
      cityName = 'Paris (défaut)';
    }
  }

  // Search city by query
  Future<void> searchCity(String query) async {
    if (query.length < 2) {
      searchResults.clear();
      update();
      return;
    }

    isSearchingCity = true;
    searchQuery = query;
    update();

    try {
      final results = await _locationService.searchCities(query);
      searchResults = results;
      debugPrint('🔍 Found ${results.length} cities');
    } catch (e) {
      debugPrint('❌ Search error: $e');
      searchResults.clear();
    }

    isSearchingCity = false;
    update();
  }

  // Select city from search
  Future<void> selectCity(CitySearchResult result) async {
    try {
      userLat = result.latitude;
      userLng = result.longitude;
      cityName = result.name;

      _calculateQibla();
      update();

      Get.back(); // Close search dialog

      Get.snackbar(
        'Ville mise à jour',
        '${result.name}, ${result.country}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('❌ City selection error: $e');
    }
  }

  /// Select city manually via dialog
  Future<void> selectCityManually() async {
    try {
      final result = await showCitySelectionDialog(Get.context!);

      if (result != null) {
        await selectCity(result);
      }
    } catch (e) {
      debugPrint('❌ City selection error: $e');
    }
  }

  // Show city search dialog
  void showCitySearchDialog(BuildContext context) {
    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return GetBuilder<QiblaController>(
            builder: (controller) {
              return Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF1E1E1E) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFFC9A84C).withValues(alpha: 0.3)
                          : const Color(0xFF1B5E20).withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFC9A84C)
                                : const Color(0xFF1B5E20),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                controller.searchCity(value);
                                setDialogState(() {});
                              },
                              decoration: InputDecoration(
                                hintText: 'Rechercher une ville...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.black45,
                                ),
                              ),
                              autofocus: true,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Get.back(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      if (controller.isSearchingCity)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        )
                      else if (controller.searchResults.isEmpty && controller.searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Aucune ville trouvée',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.searchResults.length,
                            itemBuilder: (context, index) {
                              final result = controller.searchResults[index];
                              return ListTile(
                                leading: Icon(
                                  Icons.location_city,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFFC9A84C)
                                      : const Color(0xFF1B5E20),
                                ),
                                title: Text(
                                  result.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  result.country,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                onTap: () => controller.selectCity(result),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _calculateQibla() {
    if (userLat == 0.0 && userLng == 0.0) return;

    final double lat1 = userLat * (math.pi / 180);
    final double lat2 = meccaLat * (math.pi / 180);
    final double dLng = (meccaLng - userLng) * (math.pi / 180);

    final double x = math.sin(dLng) * math.cos(lat2);
    final double y = math.cos(lat1) * math.sin(lat2) -
                     math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    double bearing = math.atan2(x, y) * (180 / math.pi);
    qiblaAngle = (bearing + 360) % 360;

    final Distance distance = Distance();
    distanceToMeccaKm = distance.as(
      LengthUnit.Kilometer,
      LatLng(userLat, userLng),
      LatLng(meccaLat, meccaLng),
    );

    debugPrint('🕋 Qibla angle: ${qiblaAngle.toStringAsFixed(1)}°');
    debugPrint('📏 Distance: ${distanceToMeccaKm.toStringAsFixed(1)} km');
  }

  Future<void> _startCompass() async {
    try {
      // Check device support using flutter_qiblah
      isCompassAvailable = await FlutterQiblah.androidDeviceSensorSupport() ?? false;

      if (!isCompassAvailable) {
        errorMessage = 'Boussole non disponible sur cet appareil';
        update(['compass']);
        return;
      }

      // Listen to qiblah stream
      // Note: QiblahDirection has 'direction' and 'qiblah' properties in some versions
      _qiblahSubscription = FlutterQiblah.qiblahStream.listen((event) {
        // Try to access event properties dynamically
        // The event object contains direction information
        try {
          // Access heading/direction from event
          final heading = (event as dynamic).direction ?? (event as dynamic).heading;
          if (heading != null) {
            compassHeading = heading.toDouble();
          }

          // Access qibla direction from event
          final qibla = (event as dynamic).qiblah ?? (event as dynamic).qiblahDirection;
          if (qibla != null) {
            qiblaAngle = qibla.toDouble();
          }

          // Calculate needle angle for display
          needleAngle = ((qiblaAngle - compassHeading) * math.pi / 180);

          update(['compass_needle']);
        } catch (e) {
          debugPrint('Error processing compass event: $e');
        }
      });

      debugPrint('🧭 Compass started, Qibla: ${qiblaAngle.toStringAsFixed(1)}°');
    } catch (e) {
      debugPrint('❌ Compass error: $e');
      isCompassAvailable = false;
      errorMessage = 'Capteur magnétique non disponible: ${e.toString()}';
      update(['compass']);
    }
  }

  void refreshLocation() async {
    _locationService.clearCache();
    isLoading = true;
    update();
    await _loadLocation();
    _calculateQibla();
    isLoading = false;
    update();
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

  @override
  void onClose() {
    _qiblahSubscription?.cancel();
    super.onClose();
  }

  void toggleCompassMode() {
    useCompassMode = !useCompassMode;
    update();
  }

  void detectCurrentAyah() {
    // No-op for compatibility
  }
}
