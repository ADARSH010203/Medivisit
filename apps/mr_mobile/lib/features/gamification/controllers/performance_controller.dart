import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';

class PerformanceController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final Rx<MrUser?> currentUser = Rx<MrUser?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedPeriod = 'month'.obs;

  // Computed metrics
  final RxDouble targetAchievement = 87.0.obs;
  final RxDouble yourAvgVisits = 8.0.obs;
  final RxDouble teamAvgVisits = 6.5.obs;
  final RxDouble avgVsLastMonth = 1.2.obs;

  // Weekly visits data (4 weeks)
  final RxList<double> weeklyVisits = <double>[42.0, 51.0, 36.0, 57.0].obs;

  // Top doctors
  final RxList<Map<String, dynamic>> topDoctors = <Map<String, dynamic>>[
    {'name': 'Dr. Jenkins', 'specialty': 'Cardiology', 'rating': 4.9, 'initials': 'DJ'},
    {'name': 'Dr. Sharma', 'specialty': 'Endocrinology', 'rating': 4.7, 'initials': 'DS'},
    {'name': 'Dr. Patel', 'specialty': 'Neurology', 'rating': 4.5, 'initials': 'DP'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    isLoading.value = true;
    try {
      currentUser.value = await _authService.getFreshUserRecord();
    } catch (e) {
      debugPrint('PerformanceController error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    // In production, reload data based on selected period
  }
}
