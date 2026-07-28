import 'package:get/get.dart';
import 'package:core/core.dart';

class AttendanceReportController extends GetxController {
  final RxList<MrUser> allMrs = <MrUser>[].obs;
  final RxString selectedMrId = ''.obs;
  final RxList<Attendance> currentMonthAttendance = <Attendance>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMrs();
  }

  Future<void> _loadMrs() async {
    final repo = Get.find<UserRepository>();
    allMrs.value = await repo.getAllMrs();
    if (allMrs.isNotEmpty) {
      selectedMrId.value = allMrs.first.uid;
      loadAttendanceForSelectedMr();
    }
  }

  void onMrSelected(String mrId) {
    selectedMrId.value = mrId;
    loadAttendanceForSelectedMr();
  }

  Future<void> loadAttendanceForSelectedMr() async {
    isLoading.value = true;
    try {
      final repo = Get.find<AttendanceRepository>();
      currentMonthAttendance.value = await repo.getAttendanceHistory(selectedMrId.value, DateTime.now());
    } finally {
      isLoading.value = false;
    }
  }
}
