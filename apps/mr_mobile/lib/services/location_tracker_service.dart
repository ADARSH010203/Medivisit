import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:core/core.dart';
import '../features/auth/controllers/auth_controller.dart';

class LocationTrackerService extends GetxService {
  final TrackingRepository _trackingRepo = Get.find<TrackingRepository>();
  final AuthController _authController = Get.find<AuthController>();
  
  Timer? _timer;
  
  @override
  void onInit() {
    super.onInit();
    _startTrackingIfActive();
    
    // Listen to auth changes
    ever(_authController.currentUser, (user) {
      if (user != null && user.isVerified) {
        _startTrackingIfActive();
      } else {
        _stopTracking();
      }
    });
  }

  void _startTrackingIfActive() {
    if (_timer != null && _timer!.isActive) return;
    
    // Only track if MR is logged in
    final user = _authController.currentUser.value;
    if (user == null || !user.isVerified) return;

    // Track every 5 minutes (300 seconds)
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _sendLocationUpdate());
    
    // Send immediate initial update
    _sendLocationUpdate();
  }

  void _stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendLocationUpdate() async {
    final user = _authController.currentUser.value;
    if (user == null) return;
    
    // Check if it's working hours (e.g. 9 AM to 6 PM)
    final now = DateTime.now();
    if (now.hour < 9 || now.hour >= 18) {
      // Out of working hours, do not send location for privacy
      return;
    }

    try {
      final hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.always || hasPermission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        
        await _trackingRepo.updateLocation(
          user.uid,
          position.latitude,
          position.longitude,
          'active',
        );
      }
    } catch (e) {
      print('LocationTrackerService error: $e');
    }
  }
  
  @override
  void onClose() {
    _stopTracking();
    super.onClose();
  }
}
