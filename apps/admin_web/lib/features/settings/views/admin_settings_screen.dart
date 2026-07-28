import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/admin_settings_controller.dart';
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminSettingsController());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: AdminGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Configuration', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          
                          AppTextField(
                            controller: controller.radiusController,
                            label: 'Geofence Radius (meters)',
                            prefixIcon: const Icon(Icons.radar_rounded),
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: controller.startTimeController,
                                  label: 'Working Hours Start (HH:MM)',
                                  prefixIcon: const Icon(Icons.access_time_rounded),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AppTextField(
                                  controller: controller.endTimeController,
                                  label: 'Working Hours End (HH:MM)',
                                  prefixIcon: const Icon(Icons.access_time_rounded),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          Obx(() => GradientButton(
                            text: controller.isLoading.value ? 'Saving...' : 'Save Settings',
                            onPressed: controller.isLoading.value ? () {} : controller.saveSettings,
                            width: 200,
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: AdminGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('System Info', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          _buildInfoRow('App Version', '1.0.0 (Build 42)'),
                          const Divider(color: AppColors.adminSurfaceHighlight, height: 32),
                          _buildInfoRow('Environment', 'Production'),
                          const Divider(color: AppColors.adminSurfaceHighlight, height: 32),
                          _buildInfoRow('Firebase', 'Connected'),
                          const Divider(color: AppColors.adminSurfaceHighlight, height: 32),
                          _buildInfoRow('Supabase', 'Connected'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
