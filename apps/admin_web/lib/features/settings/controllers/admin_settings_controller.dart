import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxBool isLoading = true.obs;
  
  final radiusController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    isLoading.value = true;
    try {
      final doc = await _firestore.collection('app_settings').doc('global').get();
      if (doc.exists) {
        final data = doc.data()!;
        radiusController.text = (data['geofenceRadius'] ?? 150).toString();
        startTimeController.text = data['workingHoursStart'] ?? '09:00';
        endTimeController.text = data['workingHoursEnd'] ?? '18:00';
      } else {
        radiusController.text = '150';
        startTimeController.text = '09:00';
        endTimeController.text = '18:00';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    isLoading.value = true;
    try {
      await _firestore.collection('app_settings').doc('global').set({
        'geofenceRadius': int.tryParse(radiusController.text) ?? 150,
        'workingHoursStart': startTimeController.text,
        'workingHoursEnd': endTimeController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      Get.snackbar('Success', 'Settings saved successfully', 
          backgroundColor: AppColors.success.withOpacity(0.8), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
