import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/territory_controller.dart';

class TerritoryManagementScreen extends StatelessWidget {
  const TerritoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TerritoryController());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Territory Management',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              GradientButton(
                text: 'Add Territory',
                width: 180,
                onPressed: () => controller.openTerritoryDialog(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AdminGlassCard(
              padding: const EdgeInsets.all(0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.territories.isEmpty) {
                  return const Center(
                    child: Text('No territories found.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingTextStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      dataTextStyle: const TextStyle(color: Colors.white),
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Region')),
                        DataColumn(label: Text('Office Location (Lat, Lng)')),
                        DataColumn(label: Text('MR Count')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: controller.territories.map((territory) {
                        return DataRow(
                          cells: [
                            DataCell(Text(territory.name)),
                            DataCell(Text(territory.region)),
                            DataCell(Text(territory.officeLocation != null ? '${territory.officeLocation!.latitude.toStringAsFixed(4)}, ${territory.officeLocation!.longitude.toStringAsFixed(4)}' : 'No Location')),
                            DataCell(Text(territory.assignedMrIds.length.toString())),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                                    onPressed: () => controller.openTerritoryDialog(territory: territory),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
                                    onPressed: () {
                                      Get.defaultDialog(
                                        title: 'Delete Territory',
                                        middleText: 'Are you sure you want to delete ${territory.name}?',
                                        backgroundColor: AppColors.adminSurface,
                                        titleStyle: const TextStyle(color: Colors.white),
                                        middleTextStyle: const TextStyle(color: Colors.white70),
                                        textConfirm: 'Delete',
                                        textCancel: 'Cancel',
                                        confirmTextColor: Colors.white,
                                        buttonColor: AppColors.error,
                                        onConfirm: () {
                                          Get.back();
                                          controller.deleteTerritory(territory.id);
                                        },
                                      );
                                    },
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
    );
  }
}
