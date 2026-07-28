import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class MarkAttendanceController extends GetxController {
  final AttendanceRepository _attendanceRepository = Get.find<AttendanceRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxString locationStatus = 'Fetching location...'.obs;
  final RxBool isLocationReady = false.obs;

  double? _lat;
  double? _lng;

  @override
  void onInit() {
    super.onInit();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    isLoading.value = true;
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        _lat = position.latitude;
        _lng = position.longitude;
        locationStatus.value = 'Location found: \n${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}';
        isLocationReady.value = true;
      } else {
        locationStatus.value = 'Failed to get location';
      }
    } catch (e) {
      locationStatus.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAttendance() async {
    if (!isLocationReady.value || _lat == null || _lng == null) {
      Get.snackbar('Error', 'Wait for location before marking attendance');
      return;
    }

    isLoading.value = true;
    try {
      final user = await _authService.getFreshUserRecord();
      final mrId = user?.uid;
      if (mrId == null) throw Exception('Not logged in');

      // Call Edge Function to verify geofence securely
      final response = await SupabaseFunctionService.verifyAttendance(
        lat: _lat!,
        lng: _lng!,
        territoryId: user?.territoryId ?? '',
      );
      final isValid = response != null && response['success'] == true;

      // Write to Firestore via repository
      await _attendanceRepository.markAttendance(
        mrId: mrId,
        lat: _lat!,
        lng: _lng!,
        geofenceVerified: isValid,
      );

      Get.snackbar(
        'Success', 
        isValid ? 'Attendance marked inside territory' : 'Attendance marked (Warning: Outside territory)',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      Get.back();
    } catch (e) {
      debugPrint('Attendance error: $e');
      Get.snackbar('Error', 'Failed to mark attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
