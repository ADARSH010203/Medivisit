import 'package:get/get.dart';
import 'package:core/core.dart';

class AdminMrManagementController extends GetxController {
  final UserRepository _userRepo = Get.find<UserRepository>();
  
  final RxList<MrUser> mrs = <MrUser>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMrs();
  }

  Future<void> _loadMrs() async {
    isLoading.value = true;
    try {
      mrs.value = await _userRepo.getAllMrs();
    } finally {
      isLoading.value = false;
    }
  }

  void viewMrDetails(String id) {
    Get.toNamed('/admin/mrs/detail', arguments: id);
  }

  Future<void> toggleSuspendMr(MrUser mr) async {
    // In a real app, update via Admin SDK function. For UI purposes we just toggle local if possible, 
    // but the repo doesn't have an update method yet.
    Get.snackbar('Feature', 'Suspend MR functionality requires Admin SDK backend setup');
  }
}
