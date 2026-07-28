import 'package:get/get.dart';
import 'package:core/core.dart';

class PerformanceController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final Rx<MrUser?> currentUser = Rx<MrUser?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    isLoading.value = true;
    try {
      currentUser.value = await _authService.getFreshUserRecord();
    } finally {
      isLoading.value = false;
    }
  }
}
