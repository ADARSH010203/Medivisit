import 'package:cloud_firestore/cloud_firestore.dart';
import '../leave_repository.dart';
import '../../models/leave_request.dart';

import 'package:get/get.dart';
import '../../services/offline_sync_service.dart';

class FirebaseLeaveRepository implements LeaveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseLeaveRepository() {
    if (Get.isRegistered<OfflineSyncService>()) {
      Get.find<OfflineSyncService>().registerHandler('submit_leave', (payload) async {
        final id = payload.remove('id');
        await _firestore.collection('leave_requests').doc(id).set(payload);
      });
    }
  }

  @override
  Future<void> submitLeave(LeaveRequest request) async {
    final docRef = _firestore.collection('leave_requests').doc();
    final newRequest = LeaveRequest(
      id: docRef.id,
      mrId: request.mrId,
      leaveType: request.leaveType,
      startDate: request.startDate,
      endDate: request.endDate,
      reason: request.reason,
      status: 'pending',
      requestedAt: DateTime.now(),
    );
    
    if (Get.isRegistered<OfflineSyncService>()) {
      final payload = newRequest.toJson();
      payload['id'] = docRef.id;
      await Get.find<OfflineSyncService>().queueAction('submit_leave', payload);
    } else {
      await docRef.set(newRequest.toJson());
    }
  }

  @override
  Future<List<LeaveRequest>> getLeaveHistory(String mrId) async {
    final snapshot = await _firestore.collection('leave_requests')
        .where('mr_id', isEqualTo: mrId)
        .orderBy('requested_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => LeaveRequest.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<LeaveRequest>> getPendingLeaves() async {
    final snapshot = await _firestore.collection('leave_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('requested_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => LeaveRequest.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<LeaveRequest>> getAllLeaves() async {
    final snapshot = await _firestore.collection('leave_requests')
        .orderBy('requested_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => LeaveRequest.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> updateLeaveStatus({
    required String leaveId,
    required String status,
    required String approvedBy,
    String? adminNote,
  }) async {
    await _firestore.collection('leave_requests').doc(leaveId).update({
      'status': status,
      'approved_by': approvedBy,
      'approved_at': DateTime.now().toIso8601String(),
      if (adminNote != null) 'admin_note': adminNote,
    });
  }
}
