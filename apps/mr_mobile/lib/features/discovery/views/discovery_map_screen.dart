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
                level: 1,
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
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.adminSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: PhosphorIcon(PhosphorIcons.user(), color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          doc.specialty,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  PhosphorIcon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Text('${doc.engagementRating.toStringAsFixed(1)} Engagement Rating'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  PhosphorIcon(PhosphorIcons.mapPin(), color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(doc.clinicAddress, style: const TextStyle(color: AppColors.textSecondary))),
                ],
              ),
              const SizedBox(height: 24),
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
        );
      },
    );
  }
}
