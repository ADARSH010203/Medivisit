import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import 'offline_sync_service.dart';

class BackgroundSyncService extends GetxService with WidgetsBindingObserver {
  late final OfflineSyncService _offlineSyncService;
  Timer? _periodicTimer;

  Future<BackgroundSyncService> init() async {
    _offlineSyncService = Get.find<OfflineSyncService>();
    WidgetsBinding.instance.addObserver(this);
    
    // Periodic background flush every 15 minutes via Workmanager
    Workmanager().registerPeriodicTask(
      "1", 
      "offlineSyncTask", 
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
    
    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Flush outbox on app foreground/resume
      _offlineSyncService.flushOutbox();
    }
  }

  Future<void> syncNow() async {
    await _offlineSyncService.retryFailedActions();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer?.cancel();
    super.onClose();
  }
}
