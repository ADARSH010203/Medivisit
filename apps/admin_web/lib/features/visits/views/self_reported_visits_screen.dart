import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/self_reported_visits_controller.dart';
import 'package:intl/intl.dart';

class SelfReportedVisitsScreen extends StatelessWidget {
  const SelfReportedVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SelfReportedVisitsController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Self-Reported Visits',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review and approve unlisted doctor visits reported by MRs.',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: AdminGlassCard(
                padding: const EdgeInsets.all(0),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.pendingVisits.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text('All caught up!', style: TextStyle(color: Colors.grey[400], fontSize: 18)),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 350), // Sidebar width approx
                      child: DataTable(
                        headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        dataTextStyle: TextStyle(color: Colors.grey[300]),
                        columns: const [
                          DataColumn(label: Text('Date & Time')),
                          DataColumn(label: Text('MR Name')),
                          DataColumn(label: Text('Doctor Name')),
                          DataColumn(label: Text('Clinic Location')),
                          DataColumn(label: Text('Location Verification')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: controller.pendingVisits.map((visit) {
                          // Parse notes for clinic details
                          final parts = visit.notes?.replaceAll('NEW DOCTOR: ', '').split(', ') ?? [];
                          final clinicDetails = parts.isNotEmpty ? parts.join(', ') : 'Unknown';

                          return DataRow(
                            cells: [
                              DataCell(Text(DateFormat('MMM dd, HH:mm').format(visit.createdAt ?? DateTime.now()))),
                              DataCell(Text('MR ID: ${visit.mrId.substring(0, 5)}...')), // Would normally fetch MR name
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(visit.doctorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    if (parts.length > 2)
                                      Text(parts[2], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                  ],
                                ),
                              ),
                              DataCell(Text(clinicDetails, maxLines: 2, overflow: TextOverflow.ellipsis)),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () => _showLocationMap(context, visit),
                                  icon: const Icon(Icons.map_rounded, size: 16),
                                  label: const Text('View Map'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Tooltip(
                                      message: 'Approve & Add Doctor',
                                      child: IconButton(
                                        icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                                        onPressed: () {
                                          Get.defaultDialog(
                                            title: 'Approve Visit',
                                            middleText: 'This will approve the visit and add ${visit.doctorName} to the system. Continue?',
                                            textConfirm: 'Approve',
                                            textCancel: 'Cancel',
                                            confirmTextColor: Colors.white,
                                            buttonColor: AppColors.success,
                                            onConfirm: () {
                                              Get.back();
                                              controller.approveVisit(visit);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Tooltip(
                                      message: 'Reject Visit',
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
                                        onPressed: () => _showRejectDialog(context, controller, visit),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationMap(BuildContext context, Visit visit) {
    final lat = visit.latitude ?? 0.0;
    final lng = visit.longitude ?? 0.0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.adminSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 600,
          height: 500,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reported Location', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
                      initialZoom: 16,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.medivisit.pro',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(lat, lng),
                            radius: 150,
                            useRadiusInMeter: true,
                            color: Colors.red.withOpacity(0.2),
                            borderColor: Colors.red,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, SelfReportedVisitsController controller, Visit visit) {
    final reasonController = TextEditingController();
    Get.defaultDialog(
      title: 'Reject Visit',
      content: Column(
        children: [
          const Text('Please provide a reason for rejection:', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. Clinic does not exist here',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            maxLines: 2,
          ),
        ],
      ),
      textConfirm: 'Reject',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      backgroundColor: AppColors.adminSurface,
      titleStyle: const TextStyle(color: Colors.white),
      onConfirm: () {
        if (reasonController.text.trim().isEmpty) {
          Get.snackbar('Error', 'Reason is required');
          return;
        }
        Get.back();
        controller.rejectVisit(visit, reasonController.text.trim());
      },
    );
  }
}
