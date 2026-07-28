import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/core.dart';
import 'dart:io';
import '../../auth/controllers/auth_controller.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository _expenseRepo = Get.find<ExpenseRepository>();
  final AuthController _authController = Get.find<AuthController>();
  final OcrService _ocrService = Get.find<OcrService>();
  
  final ImagePicker _picker = ImagePicker();
  
  final Rx<File?> receiptImage = Rx<File?>(null);
  final RxBool isProcessing = false.obs;
  final RxString selectedCategory = 'Travel'.obs;
  
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final vendorController = TextEditingController();
  final notesController = TextEditingController();

  final categories = ['Travel', 'Food', 'Accommodation', 'Samples', 'Stationery', 'Other'];

  @override
  void onInit() {
    super.onInit();
    dateController.text = DateTime.now().toIso8601String().split('T')[0];
  }

  Future<void> pickReceipt(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
      if (image != null) {
        receiptImage.value = File(image.path);
        _processReceipt(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> _processReceipt(String path) async {
    isProcessing.value = true;
    try {
      final details = await _ocrService.extractExpenseDetails(path);
      
      if (details['total'] != null && details['total']!.isNotEmpty) {
        amountController.text = details['total']!;
      }
      if (details['date'] != null && details['date']!.isNotEmpty) {
        dateController.text = details['date']!;
      }
      if (details['vendor'] != null && details['vendor']!.isNotEmpty) {
        vendorController.text = details['vendor']!;
      }
      
      Get.snackbar('OCR Complete', 'Receipt details extracted. Please verify before submitting.', 
          backgroundColor: AppColors.success.withOpacity(0.8), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('OCR Failed', 'Could not extract details. Please enter manually.');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> submitExpense() async {
    final user = _authController.currentUser.value;
    if (user == null) return;
    
    if (amountController.text.isEmpty || dateController.text.isEmpty) {
      Get.snackbar('Error', 'Amount and Date are required');
      return;
    }

    isProcessing.value = true;
    try {
      final expense = Expense(
        id: '',
        mrId: user.uid,
        category: selectedCategory.value,
        vendor: vendorController.text,
        amount: double.tryParse(amountController.text) ?? 0.0,
        currency: 'INR',
        expenseDate: dateController.text,
        receiptImageUrl: receiptImage.value?.path,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        status: ExpenseStatus.pending,
        createdAt: DateTime.now(),
      );

      await _expenseRepo.submitExpense(expense);
      
      Get.back();
      Get.snackbar('Success', 'Expense submitted successfully!', 
          backgroundColor: AppColors.success.withOpacity(0.8), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit expense: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    dateController.dispose();
    vendorController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
