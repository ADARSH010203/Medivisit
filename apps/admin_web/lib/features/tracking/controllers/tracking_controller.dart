import 'dart:async';
import 'package:get/get.dart';
import 'package:core/core.dart';

class TrackingController extends GetxController {
  final TrackingRepository _trackingRepo = Get.find<TrackingRepository>();
  
  final RxList<Map<String, dynamic>> activeMRs = <Map<String, dynamic>>[].obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  void _startListening() {
    _subscription = _trackingRepo.streamActiveMRLocations().listen((locations) {
      activeMRs.value = locations;
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
