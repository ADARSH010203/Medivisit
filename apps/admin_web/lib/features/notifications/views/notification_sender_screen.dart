import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_sender_controller.dart';

class NotificationSenderScreen extends GetView<NotificationSenderController> {
  const NotificationSenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: const Text('Send Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Target Audience',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedTargetType.value,
                dropdownColor: AppColors.adminSurface,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.adminSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All MRs')),
                  DropdownMenuItem(value: 'territory', child: Text('Specific Territory')),
                  DropdownMenuItem(value: 'mr', child: Text('Specific MR')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedTargetType.value = val;
                    controller.selectedTargetId.value = '';
                  }
                },
              )),
              const SizedBox(height: 16),
              
              Obx(() {
                if (controller.selectedTargetType.value == 'mr') {
                  return DropdownButtonFormField<String>(
                    value: controller.selectedTargetId.value.isEmpty ? null : controller.selectedTargetId.value,
                    hint: const Text('Select MR', style: TextStyle(color: Colors.white54)),
                    dropdownColor: AppColors.adminSurface,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.adminSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: controller.mrs.map((mr) {
                      return DropdownMenuItem(value: mr.uid, child: Text(mr.name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedTargetId.value = val;
                    },
                  );
                } else if (controller.selectedTargetType.value == 'territory') {
                  return TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter Territory ID',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: AppColors.adminSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => controller.selectedTargetId.value = val,
                  );
                }
                return const SizedBox.shrink();
              }),
              
              const SizedBox(height: 24),
              const Text(
                'Message Details',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Notification Title',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: AppColors.adminSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.bodyController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Notification Body...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: AppColors.adminSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.imageUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Image URL (Optional)',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: AppColors.adminSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adminAccentStart,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isLoading.value ? null : controller.sendNotification,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Send Notification',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
