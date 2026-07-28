import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/admin_mr_management_controller.dart';

class AdminMrManagementScreen extends StatelessWidget {
  const AdminMrManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminMrManagementController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MR Management', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GradientButton(
              text: 'Export Data',
              width: 120,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return AdminGlassCard(
            child: ListView.separated(
              itemCount: controller.mrs.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final mr = controller.mrs[index];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mr.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(mr.email, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Territory: ${mr.territoryId ?? 'Unassigned'}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                          Text('Total Visits: ${mr.totalVisits}', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                        ],
                      ),
                    ),
                    StatusPill(
                      text: mr.isBlocked ? 'Suspended' : 'Active',
                      type: mr.isBlocked ? StatusPillType.error : StatusPillType.success,
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.white70),
                      onPressed: () => controller.viewMrDetails(mr.uid),
                    ),
                    IconButton(
                      icon: const Icon(Icons.block, color: AppColors.warning),
                      onPressed: () => controller.toggleSuspendMr(mr),
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
