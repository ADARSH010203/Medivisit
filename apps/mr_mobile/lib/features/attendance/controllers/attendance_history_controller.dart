import 'package:get/get.dart';
import 'package:core/core.dart';

class AttendanceHistoryController extends GetxController {
  final AttendanceRepository _attendanceRepository = Get.find<AttendanceRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final RxMap<DateTime, List<Attendance>> events = <DateTime, List<Attendance>>{}.obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime?> selectedDay = Rx<DateTime?>(null);
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMonth(focusedDay.value);
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(selectedDay.value, selected)) {
      selectedDay.value = selected;
      focusedDay.value = focused;
    }
  }

  void onPageChanged(DateTime focused) {
    focusedDay.value = focused;
    loadMonth(focused);
  }

  Future<void> loadMonth(DateTime month) async {
    isLoading.value = true;
    try {
      final user = await _authService.getFreshUserRecord();
      final mrId = user?.uid;
      if (mrId == null) return;

      final history = await _attendanceRepository.getAttendanceHistory(mrId, month);
      
      final Map<DateTime, List<Attendance>> newEvents = {};
      for (var record in history) {
        // Strip time for calendar mapping
        final date = DateTime.utc(
          record.attendanceDate.year, 
          record.attendanceDate.month, 
          record.attendanceDate.day
        );
        newEvents[date] = [record];
      }
      events.value = newEvents;
    } finally {
      isLoading.value = false;
    }
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
