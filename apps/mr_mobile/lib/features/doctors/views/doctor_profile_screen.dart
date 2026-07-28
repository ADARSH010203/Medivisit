import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/doctor_profile_controller.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorProfileController());
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: MeshGradientBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctor = controller.doctor.value;
          if (doctor == null) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: doctor.photoUrl != null
                          ? ClipOval(child: Image.network(doctor.photoUrl!, fit: BoxFit.cover))
                          : const Icon(Icons.person, size: 64, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    doctor.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${doctor.specialty} • ${doctor.clinicName}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.location_on, doctor.clinicAddress),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.phone, doctor.phone),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GradientButton(
                    text: 'Start Visit',
                    onPressed: controller.startVisit,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
