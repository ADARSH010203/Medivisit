import 'package:cloud_firestore/cloud_firestore.dart';
import '../attendance_repository.dart';
import '../../models/attendance.dart';

import 'package:get/get.dart';
import '../../services/offline_sync_service.dart';

class FirebaseAttendanceRepository implements AttendanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAttendanceRepository() {
    if (Get.isRegistered<OfflineSyncService>()) {
      Get.find<OfflineSyncService>().registerHandler('mark_attendance', (payload) async {
        final id = payload.remove('_doc_id') as String?;
        if (id == null || id.isEmpty) return;
        await _firestore.collection('attendance').doc(id).set(payload);
      });
    }
  }

  @override
  Future<void> markAttendance({
    required String mrId,
    required double lat,
    required double lng,
    required bool geofenceVerified,
  }) async {
    final now = DateTime.now();
    final docRef = _firestore.collection('attendance').doc();
    final hourStr = now.hour.toString().padLeft(2, '0');
    final minStr = now.minute.toString().padLeft(2, '0');
    
    final attendance = Attendance(
      id: docRef.id,
      mrId: mrId,
      attendanceDate: DateTime(now.year, now.month, now.day),
      attendanceTime: '$hourStr:$minStr',
      latitude: lat,
      longitude: lng,
      locationTimestamp: now,
      geofenceVerified: geofenceVerified,
      status: 'present',
      createdAt: now,
    );

    if (Get.isRegistered<OfflineSyncService>()) {
      final payload = attendance.toJson();
      payload['_doc_id'] = docRef.id;
      await Get.find<OfflineSyncService>().queueAction('mark_attendance', payload);
    } else {
      await docRef.set(attendance.toJson());
    }
  }

  @override
  Future<List<Attendance>> getAttendanceHistory(String mrId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final snapshot = await _firestore.collection('attendance')
        .where('mr_id', isEqualTo: mrId)
        .where('attendance_date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
        .where('attendance_date', isLessThanOrEqualTo: endOfMonth.toIso8601String())
        .get();

    return snapshot.docs.map((doc) => Attendance.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<Attendance?> getTodayAttendance(String mrId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final snapshot = await _firestore.collection('attendance')
        .where('mr_id', isEqualTo: mrId)
        .where('attendance_date', isEqualTo: today.toIso8601String())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Attendance.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
  }
}
