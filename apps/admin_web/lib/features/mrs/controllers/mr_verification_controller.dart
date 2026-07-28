import 'package:get/get.dart';
import 'package:core/core.dart';

class MrVerificationController extends GetxController {
  final UserRepository _userRepo = Get.find<UserRepository>();

  final RxList<MrUser> pendingMrs = <MrUser>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPendingMrs();
  }

  Future<void> _loadPendingMrs() async {
    try {
      isLoading.value = true;
      final unverified = await _userRepo.getUnverifiedUsers();
      pendingMrs.assignAll(unverified);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load unverified users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveMr(String uid) async {
    try {
      isLoading.value = true;
      await _userRepo.updateUser(uid, {'is_verified': true});
      pendingMrs.removeWhere((mr) => mr.uid == uid);
      Get.snackbar('Success', 'MR has been verified.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve MR: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectMr(String uid) async {
    try {
      isLoading.value = true;
      // Depending on rules, maybe delete or just mark rejected. For now, mark blocked.
      await _userRepo.updateUser(uid, {'is_blocked': true});
      pendingMrs.removeWhere((mr) => mr.uid == uid);
      Get.snackbar('Success', 'MR has been rejected.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject MR: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
