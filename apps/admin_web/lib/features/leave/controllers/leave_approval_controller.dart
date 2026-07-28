import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaveApprovalController extends GetxController {
  final LeaveRepository _leaveRepository = Get.find<LeaveRepository>();

  final RxList<LeaveRequest> allRequests = <LeaveRequest>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    isLoading.value = true;
    try {
      allRequests.value = await _leaveRepository.getAllLeaves();
    } finally {
      isLoading.value = false;
    }
  }

  List<LeaveRequest> get pendingRequests => 
      allRequests.where((r) => r.status.toLowerCase() == 'pending').toList();
      
  List<LeaveRequest> get approvedRequests => 
      allRequests.where((r) => r.status.toLowerCase() == 'approved').toList();
      
  List<LeaveRequest> get rejectedRequests => 
      allRequests.where((r) => r.status.toLowerCase() == 'rejected').toList();

  Future<void> updateStatus(LeaveRequest request, String status, String note) async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      await _leaveRepository.updateLeaveStatus(
        leaveId: request.id, 
        status: status,
        approvedBy: user?.uid ?? 'admin', 
        adminNote: note,
      );
      
      // Call Edge Function or just use repository if it triggers function.
      // But we will use the Service here
      await SupabaseFunctionService.sendNotification(
        title: 'Leave Request $status',
        body: 'Your leave request for ${request.leaveType} has been $status.',
        targetType: 'mr',
        targetId: request.mrId,
        notificationType: 'leave_update',
      );

      Get.snackbar('Success', 'Leave request marked as $status');
      await _loadRequests();
    } catch (e) {
      debugPrint('Error updating leave: $e');
      Get.snackbar('Error', 'Failed to update status');
    } finally {
      isLoading.value = false;
    }
  }
}
