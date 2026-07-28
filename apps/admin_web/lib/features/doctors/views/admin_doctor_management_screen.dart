import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/admin_doctor_management_controller.dart';

class AdminDoctorManagementScreen extends StatelessWidget {
  const AdminDoctorManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDoctorManagementController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Doctor Management', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GradientButton(
              text: '+ Add Doctor',
              width: 150,
              onPressed: controller.addDoctor,
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
              itemCount: controller.doctors.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final doctor = controller.doctors[index];
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
                          Text(doctor['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${doctor['specialty']} • ${doctor['clinic']}', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                        ],
                      ),
                    ),
                    StatusPill(text: doctor['status'], type: StatusPillType.success),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () => controller.editDoctor(doctor['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => controller.deleteDoctor(doctor['id']),
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
