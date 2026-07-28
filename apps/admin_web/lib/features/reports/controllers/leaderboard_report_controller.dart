import 'package:get/get.dart';
import 'package:core/core.dart';

class LeaderboardReportController extends GetxController {
  final LeaderboardRepository _leaderboardRepo = Get.find<LeaderboardRepository>();
  
  final RxString selectedPeriod = 'monthly'.obs;
  final RxList<LeaderboardEntry> leaderboard = <LeaderboardEntry>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    isLoading.value = true;
    try {
      if (selectedPeriod.value == 'weekly') {
        leaderboard.value = await _leaderboardRepo.getWeeklyLeaderboard();
      } else {
        leaderboard.value = await _leaderboardRepo.getMonthlyLeaderboard();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadLeaderboard();
  }
}
