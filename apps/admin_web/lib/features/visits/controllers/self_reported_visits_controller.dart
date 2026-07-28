import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/controllers/admin_auth_controller.dart';

class SelfReportedVisitsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminAuthController _authController = Get.find<AdminAuthController>();

  final RxList<Visit> pendingVisits = <Visit>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _streamPendingVisits();
  }

  void _streamPendingVisits() {
    _firestore
        .collection('visits')
        .where('visit_source', isEqualTo: 'self_reported')
        .where('admin_review_status', isEqualTo: 'pending')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      pendingVisits.value = snapshot.docs.map((doc) => Visit.fromFirestore(doc)).toList();
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Error streaming self-reported visits: $e');
      isLoading.value = false;
    });
  }

  Future<void> approveVisit(Visit visit) async {
    try {
      final user = _authController.currentUser.value;
      
      // If it's a new doctor (id not found in doctors collection)
      // wait, we don't know if it's new or existing. 
      // The requirement: "If it's a new doctor, create it."
      // Let's check if the doctor exists.
      final docRef = _firestore.collection('doctors').doc(visit.doctorId);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // We need to construct the Doctor object from Visit notes (which contains clinic name etc.)
        // But since we created the doctor ID but didn't save it, wait, we don't have all doctor fields in the Visit object!
        // Ah, in DoctorQuickLogController, we stored: 'NEW DOCTOR: Clinic Name, Address, Specialty' in notes.
        // Let's parse it back, or better, we should have saved the Doctor temporarily or we can just create a basic one.
        final parts = visit.notes?.replaceAll('NEW DOCTOR: ', '').split(', ') ?? [];
        final clinicName = parts.isNotEmpty ? parts[0] : 'Unknown Clinic';
        final address = parts.length > 1 ? parts[1] : 'Unknown Address';
        final specialty = parts.length > 2 ? parts[2] : 'General Physician';

        final newDoc = Doctor(
          id: visit.doctorId,
          name: visit.doctorName,
          specialty: specialty,
          qualification: 'Unknown',
          clinicName: clinicName,
          clinicAddress: address,
          clinicLocation: GeoPoint(visit.latitude ?? 0, visit.longitude ?? 0),
          geofenceRadiusM: 150,
          phone: '',
          bio: 'Self-reported by MR ${visit.mrId}',
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
          timingStart: '09:00',
          timingEnd: '17:00',
          isActive: true,
          isHighPriority: false,
          totalVisits: 1,
          source: 'mr_reported',
          reportedByMr: visit.mrId,
          createdAt: DateTime.now(),
        );
        await docRef.set(newDoc.toFirestore());
      } else {
        // Update visit count
        await docRef.update({'total_visits': FieldValue.increment(1)});
      }

      await _firestore.collection('visits').doc(visit.id).update({
        'admin_review_status': 'approved',
        'reviewed_by': user?.uid,
        'reviewed_at': FieldValue.serverTimestamp(),
      });

      // Send notification back to MR
      await SupabaseFunctionService.sendNotification(
        title: 'Visit Approved',
        body: 'Your visit to Dr. ${visit.doctorName} has been verified!',
        targetType: 'mr',
        targetId: visit.mrId,
      );

      Get.snackbar('Success', 'Visit approved and doctor added to system.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> rejectVisit(Visit visit, String reason) async {
    try {
      final user = _authController.currentUser.value;
      
      await _firestore.collection('visits').doc(visit.id).update({
        'admin_review_status': 'rejected',
        'admin_review_note': reason,
        'reviewed_by': user?.uid,
        'reviewed_at': FieldValue.serverTimestamp(),
      });

      // Send notification back to MR
      await SupabaseFunctionService.sendNotification(
        title: 'Visit Rejected',
        body: 'Visit rejected: $reason',
        targetType: 'mr',
        targetId: visit.mrId,
      );

      Get.snackbar('Success', 'Visit rejected.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
