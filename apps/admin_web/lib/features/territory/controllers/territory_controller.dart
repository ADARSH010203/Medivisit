import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';

class TerritoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<Territory> territories = <Territory>[].obs;
  final RxBool isLoading = true.obs;

  final nameController = TextEditingController();
  final regionController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTerritories();
  }

  Future<void> loadTerritories() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore.collection('territories').orderBy('name').get();
      territories.value = snapshot.docs.map((doc) => Territory.fromFirestore(doc)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load territories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveTerritory({String? id}) async {
    if (nameController.text.isEmpty || regionController.text.isEmpty) {
      Get.snackbar('Error', 'Name and Region are required');
      return;
    }

    final lat = double.tryParse(latController.text) ?? 0.0;
    final lng = double.tryParse(lngController.text) ?? 0.0;

    isLoading.value = true;
    try {
      final data = {
        'name': nameController.text,
        'region': regionController.text,
        'officeLocation': GeoPoint(lat, lng),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (id == null) {
        data['mrCount'] = 0;
        data['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('territories').add(data);
        Get.snackbar('Success', 'Territory created');
      } else {
        await _firestore.collection('territories').doc(id).update(data);
        Get.snackbar('Success', 'Territory updated');
      }
      
      Get.back(); // close dialog
      loadTerritories();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save territory: $e');
      isLoading.value = false;
    }
  }

  Future<void> deleteTerritory(String id) async {
    try {
      await _firestore.collection('territories').doc(id).delete();
      loadTerritories();
      Get.snackbar('Success', 'Territory deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete territory: $e');
    }
  }

  void openTerritoryDialog({Territory? territory}) {
    if (territory != null) {
      nameController.text = territory.name;
      regionController.text = territory.region;
      latController.text = territory.officeLocation?.latitude.toString() ?? '0.0';
      lngController.text = territory.officeLocation?.longitude.toString() ?? '0.0';
    } else {
      nameController.clear();
      regionController.clear();
      latController.clear();
      lngController.clear();
    }

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.adminSurface,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                territory == null ? 'Add Territory' : 'Edit Territory',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),
              AppTextField(controller: nameController, label: 'Territory Name', prefixIcon: const Icon(Icons.map)),
              const SizedBox(height: 16),
              AppTextField(controller: regionController, label: 'Region', prefixIcon: const Icon(Icons.location_city)),
              const SizedBox(height: 16),
              AppTextField(controller: latController, label: 'Office Latitude', prefixIcon: const Icon(Icons.gps_fixed)),
              const SizedBox(height: 16),
              AppTextField(controller: lngController, label: 'Office Longitude', prefixIcon: const Icon(Icons.gps_fixed)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  GradientButton(
                    text: 'Save',
                    onPressed: () => saveTerritory(id: territory?.id),
                    width: 120,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    regionController.dispose();
    latController.dispose();
    lngController.dispose();
    super.onClose();
  }
}
