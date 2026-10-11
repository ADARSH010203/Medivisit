import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/doctor_filter_controller.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/result_card.dart';

class DiscoveryMapScreen extends StatelessWidget {
  const DiscoveryMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorFilterController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GlassCard(
            level: 1,
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final center = controller.currentLocation.value ?? const LatLng(0, 0);

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
              ),
              children: [
                _buildMapLayer(controller.filter.value.mapLayer),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(50),
                    maxZoom: 15,
                    markers: controller.filteredDoctors.map((doc) => _buildMarker(doc, context)).toList(),
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Current Location Marker
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 24,
                      height: 24,
                      child: const Icon(Icons.my_location_rounded, color: Colors.blue, size: 24),
                    ),
                  ],
                ),
              ],
            ),
            
            // Result Card
            const Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: ResultCard(),
            ),

            // Layers / Filter FAB
            Positioned(
              bottom: 32,
              right: 16,
              child: GlassCard(
                level: 2,
                padding: EdgeInsets.zero,
                child: IconButton(
                  icon: PhosphorIcon(PhosphorIcons.stack(), color: AppColors.primary, size: 28),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const FilterBottomSheet(),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMapLayer(MapLayerType type) {
    String url;
    switch (type) {
      case MapLayerType.satellite:
        // Normally requires API key for real satellite imagery, using placeholder OSM variant
        url = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
        break;
      case MapLayerType.terrain:
        url = 'https://tile.opentopomap.org/{z}/{x}/{y}.png';
        break;
      case MapLayerType.standard:
      default:
        url = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }

    Widget layer = TileLayer(
      urlTemplate: url,
      userAgentPackageName: 'com.medivisit.pro',
    );

    // Apply clinical futurism dark filter to standard map
    if (type == MapLayerType.standard) {
      layer = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          -1,  0,  0, 0, 255,
           0, -1,  0, 0, 255,
           0,  0, -1, 0, 255,
           0,  0,  0, 1,   0,
        ]),
        child: layer,
      );
    }

    return layer;
  }

  Marker _buildMarker(Doctor doc, BuildContext context) {
    return Marker(
      point: LatLng(doc.clinicLocation.latitude, doc.clinicLocation.longitude),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          _showDoctorPreview(context, doc);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (doc.isHighPriority)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tertiary.withOpacity(0.8),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            PhosphorIcon(
              PhosphorIcons.stethoscope(PhosphorIconsStyle.fill),
              color: doc.isHighPriority ? AppColors.tertiary : AppColors.primary,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorPreview(BuildContext context, Doctor doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark ? const Color(0xFF151C27) : Colors.white;

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.75),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(isDark ? 0.1 : 0.4),
                    width: 1.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.secondary.withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            PhosphorIcons.user(PhosphorIconsStyle.duotone),
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1D1B20),
                              ),
                            ),
                            Text(
                              doc.specialty,
                              style: TextStyle(
                                color: isDark ? Colors.white60 : const Color(0xFF494551),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Info rows inside a GlassCard
                  GlassCard(
                    level: 1,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            PhosphorIcon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: AppColors.warning, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${doc.engagementRating.toStringAsFixed(1)} Engagement Rating',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1D1B20),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.mapPin(PhosphorIconsStyle.duotone),
                              color: isDark ? Colors.white54 : const Color(0xFF494551),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                doc.clinicAddress,
                                style: TextStyle(
                                  color: isDark ? Colors.white54 : const Color(0xFF494551),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    text: 'View Full Profile',
                    onPressed: () {
                      Get.back();
                      // TODO: Navigate to Doctor Profile
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
