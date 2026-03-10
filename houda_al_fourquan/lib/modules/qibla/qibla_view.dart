import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import 'qibla_controller.dart';

class QiblaView extends StatelessWidget {
  const QiblaView({super.key});

  @override
  Widget build(BuildContext context) {
    final QiblaController controller = Get.put(QiblaController());

    return Scaffold(
      backgroundColor: DT.bg(context),
      appBar: AppBar(
        title: Text('القبلة', style: DT.titleLg(context)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: DT.accentGrad(context),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: DT.blanc),
            onPressed: () => controller.refreshLocation(),
            tooltip: 'Actualiser'.trx,
          ),
        ],
      ),
      body: GetBuilder<QiblaController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: DT.accent(context),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Calcul...', style: DT.sub(context)),
                ],
              ),
            );
          }

          if (controller.errorMessage.isNotEmpty &&
              !controller.isCompassAvailable) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.compass_calibration_outlined,
                      size: 48,
                      color: DT.subC(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage,
                      textAlign: TextAlign.center,
                      style: DT.sub(context),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => controller.refreshLocation(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text('Réessayer'.trx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DT.accent(context),
                        foregroundColor: DT.blanc,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              InfoBannerWidget(controller: controller),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      QiblaDirectionWidget(controller: controller),
                      const SizedBox(height: 12),
                      QiblaMapWidget(controller: controller),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Banner Widget
// ─────────────────────────────────────────────────────────────────────────────
class InfoBannerWidget extends StatelessWidget {
  final QiblaController controller;

  const InfoBannerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QiblaController>(
      builder: (controller) {
        return GestureDetector(
          onTap: () => controller.showCitySearchDialog(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: DT.accentGrad(context)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DT.borderColor(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoColumn(
                  icon: Icons.location_city,
                  value: controller.cityName,
                  label: 'Ville'.trx,
                  showSearchIcon: true,
                ),
                _InfoColumn(
                  icon: Icons.gps_fixed,
                  value: '${controller.userLat.toStringAsFixed(2)}°',
                  label: 'Lat',
                ),
                _InfoColumn(
                  icon: Icons.straighten,
                  value: '${controller.distanceToMeccaKm.toStringAsFixed(0)}km',
                  label: 'Dist',
                ),
                _InfoColumn(
                  icon: Icons.explore,
                  value: '${controller.qiblaAngle.toStringAsFixed(0)}°',
                  label: 'Qibla',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool showSearchIcon;

  const _InfoColumn({
    required this.icon,
    required this.value,
    required this.label,
    this.showSearchIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: DT.blanc),
            if (showSearchIcon) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.search,
                size: 14,
                color: DT.blanc.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: DT.blanc,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: DT.blanc.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Qibla Direction Widget (Compass-like) - COMPACT
// ─────────────────────────────────────────────────────────────────────────────
class QiblaDirectionWidget extends StatelessWidget {
  final QiblaController controller;

  const QiblaDirectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QiblaController>(
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: DT.accentGrad(context)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: DT.accent(context).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Qibla',
                    style: TextStyle(
                      color: DT.blanc,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${controller.qiblaAngle.toStringAsFixed(0)}°',
                    style: TextStyle(
                      color: DT.blanc.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Compact compass dial
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass background
                    Transform.rotate(
                      angle: -(controller.compassHeading * math.pi / 180),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DT.blanc.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          color: DT.blanc.withValues(alpha: 0.1),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 4,
                              child: Text(
                                'N',
                                style: TextStyle(
                                  color: DT.blanc.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              child: Text(
                                'S',
                                style: TextStyle(
                                  color: DT.blanc.withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 4,
                              child: Text(
                                'E',
                                style: TextStyle(
                                  color: DT.blanc.withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 4,
                              child: Text(
                                'W',
                                style: TextStyle(
                                  color: DT.blanc.withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Qibla arrow
                    Transform.rotate(
                      angle: (controller.qiblaAngle * math.pi / 180),
                      child: SizedBox(
                        width: 4,
                        height: 60,
                        child: Column(
                          children: [
                            Container(
                              width: 0,
                              height: 0,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.transparent,
                                    width: 8,
                                  ),
                                  right: BorderSide(
                                    color: Colors.transparent,
                                    width: 8,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.amber,
                                    width: 14,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 35,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Center dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: DT.blanc, width: 2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Info box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DT.blanc.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.near_me, color: Colors.amber, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Vers La Mecque',
                      style: const TextStyle(color: DT.blanc, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Qibla Map Widget
// ─────────────────────────────────────────────────────────────────────────────
class QiblaMapWidget extends StatefulWidget {
  final QiblaController controller;

  const QiblaMapWidget({super.key, required this.controller});

  @override
  State<QiblaMapWidget> createState() => _QiblaMapWidgetState();
}

class _QiblaMapWidgetState extends State<QiblaMapWidget> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(QiblaMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // No auto-move, user can pan/zoom manually
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QiblaController>(
      builder: (controller) {
        // Center map on Africa (approximate center: 0°N, 20°E)
        final africaCenter = const LatLng(0, 20);
        final userPoint = LatLng(controller.userLat, controller.userLng);
        final meccaPoint = LatLng(
          QiblaController.meccaLat,
          QiblaController.meccaLng,
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DT.borderColor(context), width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: africaCenter,
              initialZoom: 1.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag
                    .all, // Enable all interactions (pan, zoom, rotate)
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.houda_al_fourquan.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [userPoint, meccaPoint],
                    color: DT.accent(context),
                    strokeWidth: 2.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userPoint,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: DT.dark(context) ? DT.or : DT.vert,
                        shape: BoxShape.circle,
                        border: Border.all(color: DT.blanc, width: 2),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: DT.blanc,
                        size: 24,
                      ),
                    ),
                  ),
                  Marker(
                    point: meccaPoint,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: DT.accent(context),
                        shape: BoxShape.circle,
                        border: Border.all(color: DT.blanc, width: 2),
                      ),
                      child: const Icon(
                        Icons.mosque,
                        color: DT.blanc,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
