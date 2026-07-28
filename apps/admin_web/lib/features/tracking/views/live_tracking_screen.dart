import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/tracking_controller.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.put(TrackingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live MR Tracking'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Obx(() {
        final activeMRs = controller.activeMRs;

        // Default to center of India if no MRs
        var centerLat = 20.5937;
        var centerLng = 78.9629;
        var zoom = 4.0;

        if (activeMRs.isNotEmpty) {
          centerLat = activeMRs.first['lat'] as double;
          centerLng = activeMRs.first['lng'] as double;
          zoom = 10.0;
        }

        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(centerLat, centerLng),
            initialZoom: zoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.medivisit.pro',
            ),
            MarkerLayer(
              markers: activeMRs.map((mrData) {
                final lat = mrData['lat'] as double;
                final lng = mrData['lng'] as double;
                final status = mrData['status'] as String? ?? 'active';
                
                final color = status == 'active' 
                    ? AppColors.success 
                    : (status == 'idle' ? AppColors.warning : Colors.grey);

                return Marker(
                  point: LatLng(lat, lng),
                  width: 40,
                  height: 40,
                  child: Tooltip(
                    message: 'MR ID: ${mrData['mr_id']}\nStatus: $status',
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Icon(Icons.person_pin_circle, color: color, size: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }),
    );
  }
}
