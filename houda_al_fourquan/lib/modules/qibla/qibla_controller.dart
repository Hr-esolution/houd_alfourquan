import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/location_service.dart';
import '../../core/services/osm_service.dart';

class QiblaController extends GetxController {
  // Coordonnées de La Mecque
  static const double meccaLat = 21.4225;
  static const double meccaLng = 39.8262;

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

  // Recherche de ville
  bool isSearchingCity = false;
  List<Map<String, dynamic>> searchResults = [];
  String searchQuery = '';

  StreamSubscription? _qiblahSubscription;
  final LocationService _locationService = LocationService();
  final OSMService _osmService = OSMService();

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
      final hasPermission = await _locationService.hasPermission();

      if (!hasPermission) {
        errorMessage = 'Permission de localisation requise';
        return;
      }

      final position = await _locationService.getCurrentLocation();
      userLat = position.latitude;
      userLng = position.longitude;
      cityName = 'Recherche...';
      update();

      // Search city name from coordinates
      await _searchCityFromCoords();

      debugPrint('📍 Location: $userLat, $userLng');
    } catch (e) {
      debugPrint('❌ Location error: $e');
      errorMessage = 'Position indisponible';
      userLat = 48.8566;
      userLng = 2.3522;
      cityName = 'Paris (défaut)';
    }
  }

  Future<void> _searchCityFromCoords() async {
    try {
      final cityNameData = await _osmService.getCity(userLat, userLng);
      if (cityNameData.isNotEmpty && cityNameData != 'Unknown') {
        cityName = cityNameData;
        debugPrint('🏙️ City: $cityName');
      } else {
        cityName = 'Position actuelle';
      }
      update();
    } catch (e) {
      debugPrint('❌ City search error: $e');
      cityName = 'Position actuelle';
      update();
    }
  }

  // Search city by query
  Future<void> searchCity(String query) async {
    if (query.length < 3) {
      searchResults.clear();
      update();
      return;
    }

    isSearchingCity = true;
    searchQuery = query;
    update();

    try {
      final results = await _osmService.searchCities(query);
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
  Future<void> selectCity(Map<String, dynamic> result) async {
    try {
      userLat = double.parse(result['lat']);
      userLng = double.parse(result['lon']);
      cityName = result['display_name'].toString().split(',').first.trim();
      
      _calculateQibla();
      update();
      
      Get.back(); // Close search dialog
      
      Get.snackbar(
        'Ville mise à jour',
        cityName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
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
                                  Icons.location_on,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFFC9A84C)
                                      : const Color(0xFF1B5E20),
                                ),
                                title: Text(
                                  result['display_name'] as String,
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
    isLoading = true;
    update();
    await _loadLocation();
    _calculateQibla();
    isLoading = false;
    update();
  }

  @override
  void onClose() {
    _qiblahSubscription?.cancel();
    super.onClose();
  }

  void detectCurrentAyah() {
    // No-op for compatibility
  }
}
