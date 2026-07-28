import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/smart_route_planner_controller.dart';

class SmartRoutePlannerScreen extends StatelessWidget {
  const SmartRoutePlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SmartRoutePlannerController());
    final theme = Theme.of(context).extension<MediVisitMobileTheme>()!;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Smart Route Planner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MeshGradientBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.optimizedRoute.isEmpty) {
            return const Center(
              child: Text(
                'No pending visits for today.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.optimizedRoute.length,
            itemBuilder: (context, index) {
              final doctor = controller.optimizedRoute[index];
              return GlassCard(
                level: 1,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(doctor.specialty, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SecondaryButton(
                      text: 'Navigate',
                      onPressed: () => controller.startNavigation(doctor),
                      width: 100,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
