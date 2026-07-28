import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'John Doe');
  final _phoneController = TextEditingController(text: '+1 (555) 123-4567');
  final controller = Get.put(EditProfileController());

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MeshGradientBackground(
        child: Obx(() {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF0053D3), Color(0xFF44DDC1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1D1B20)
                                : const Color(0xFFEADDFF),
                          ),
                          child: Center(
                            child: PhosphorIcon(
                              PhosphorIcons.user(PhosphorIconsStyle.duotone),
                              size: 40,
                              color: const Color(0xFF0053D3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0053D3),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                        child: PhosphorIcon(
                          PhosphorIcons.camera(PhosphorIconsStyle.fill),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Personal Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1D1B20),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 48),
              GradientButton(
                text: 'Save Changes',
                isLoading: controller.isLoading.value,
                onPressed: controller.saveProfile,
              ),
            ],
          );
        }),
      ),
    );
  }
}
