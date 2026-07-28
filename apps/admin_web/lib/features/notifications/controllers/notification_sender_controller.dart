import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class NotificationSenderController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  
  final RxString selectedTargetType = 'all'.obs; // all, territory, mr
  final RxString selectedTargetId = ''.obs;
  
  final RxList<MrUser> mrs = <MrUser>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMrs();
  }

  Future<void> _loadMrs() async {
    final repo = Get.find<UserRepository>();
    mrs.value = await repo.getAllMrs();
  }

  Future<void> sendNotification() async {
    if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title and body are required');
      return;
    }
    
    if (selectedTargetType.value != 'all' && selectedTargetId.value.isEmpty) {
      Get.snackbar('Error', 'Please select a specific target');
      return;
    }

    isLoading.value = true;
    try {
      await SupabaseFunctionService.sendNotification(
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
        targetType: selectedTargetType.value,
        targetId: selectedTargetType.value == 'all' ? null : selectedTargetId.value,
        notificationType: 'announcement',
        imageUrl: imageUrlController.text.trim().isNotEmpty ? imageUrlController.text.trim() : null,
      );
      
      Get.snackbar('Success', 'Notification sent successfully');
      titleController.clear();
      bodyController.clear();
      imageUrlController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notification: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
