import 'package:get/get.dart';

class EditProfileController extends GetxController {
  final isLoading = false.obs;
  
  void saveProfile() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      Get.back();
      Get.snackbar('Success', 'Profile updated successfully');
    });
  }
}
