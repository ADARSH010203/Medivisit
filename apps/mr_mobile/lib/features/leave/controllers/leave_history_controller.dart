import 'package:get/get.dart';
import 'package:core/core.dart';

class LeaveHistoryController extends GetxController {
  final LeaveRepository _leaveRepository = Get.find<LeaveRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<LeaveRequest> leaveRequests = <LeaveRequest>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final user = await _authService.getFreshUserRecord();
      if (user == null) return;
      
      leaveRequests.value = await _leaveRepository.getLeaveHistory(user.uid);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load leave history: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
