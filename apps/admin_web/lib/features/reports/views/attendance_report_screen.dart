import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_report_controller.dart';
import 'package:intl/intl.dart';

class AttendanceReportScreen extends GetView<AttendanceReportController> {
  const AttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: const Text('Attendance Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar for MR selection
          Container(
            width: 300,
            color: AppColors.adminSurface,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select MR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.allMrs.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: controller.allMrs.length,
                      itemBuilder: (context, index) {
                        final mr = controller.allMrs[index];
                        return Obx(() => ListTile(
                          title: Text(mr.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(mr.territoryId ?? 'No Territory', style: const TextStyle(color: Colors.white54)),
                          selected: controller.selectedMrId.value == mr.uid,
                          selectedTileColor: AppColors.adminAccentStart.withOpacity(0.2),
                          onTap: () => controller.onMrSelected(mr.uid),
                        ));
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          
          // Main content for attendance list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Month Attendance',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.adminAccentStart));
                      }

                      if (controller.currentMonthAttendance.isEmpty) {
                        return const Center(
                          child: Text(
                            'No attendance records found for this MR this month.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: controller.currentMonthAttendance.length,
                        itemBuilder: (context, index) {
                          final record = controller.currentMonthAttendance[index];
                          final isVerified = record.geofenceVerified;
                          return Card(
                            color: AppColors.adminSurface,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                isVerified ? Icons.check_circle : Icons.warning_amber_rounded,
                                color: isVerified ? Colors.greenAccent : Colors.orangeAccent,
                              ),
                              title: Text(
                                DateFormat.yMMMd().format(record.attendanceDate),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Marked at ${record.attendanceTime} • ${isVerified ? "Within Territory" : "Outside Geofence"}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Text(
                                record.status.toUpperCase(),
                                style: TextStyle(
                                  color: record.status == 'present' ? Colors.greenAccent : Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
