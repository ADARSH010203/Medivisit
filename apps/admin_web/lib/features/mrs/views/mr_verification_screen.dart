import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/mr_verification_controller.dart';

class MrVerificationScreen extends StatelessWidget {
  const MrVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MrVerificationController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MR Verifications Queue', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Obx(() {
          if (controller.isLoading.value && controller.pendingMrs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.pendingMrs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                  SizedBox(height: 16),
                  Text('All caught up! No MRs waiting for verification.', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.pendingMrs.length,
            itemBuilder: (context, index) {
              final mr = controller.pendingMrs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AdminGlassCard(
                  child: Row(
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
                          Text('Phone: ${mr.phone}', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        GradientButton(
                          text: 'Approve',
                          width: 120,
                          onPressed: () => controller.approveMr(mr.uid),
                        ),
                        const SizedBox(height: 8),
                        SecondaryButton(
                          text: 'Reject',
                          width: 120,
                          onPressed: () => controller.rejectMr(mr.uid),
                        ),
                      ],
                    )
                  ],
                ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
