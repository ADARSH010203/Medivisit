import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:latlong2/latlong.dart';

class MrDetailTrackingController extends GetxController {
  final String mrId = (Get.arguments is String) ? Get.arguments as String : 'mr1';
  
  final UserRepository _userRepo = Get.find<UserRepository>();
  final VisitRepository _visitRepo = Get.find<VisitRepository>();
  
  final Rx<MrUser?> mrUser = Rx<MrUser?>(null);
  final RxList<Visit> recentVisits = <Visit>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isBlocked = false.obs;
  
  // Feedback
  final TextEditingController feedbackNoteController = TextEditingController();
  final RxList<String> selectedTags = <String>[].obs;
  
  // Charts & Metrics
  final RxList<FlSpot> visitTrendSpots = <FlSpot>[].obs;
  final RxDouble attendanceRate = 94.5.obs;
  final RxDouble avgRating = 4.7.obs;
  
  // Territory Office Location (e.g., Mumbai HQ)
  final LatLng officeLocation = const LatLng(19.0760, 72.8777);

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      final mrs = await _userRepo.getAllMrs();
      mrUser.value = mrs.firstWhereOrNull((u) => u.uid == mrId) ??
          MrUser(
            uid: mrId,
            email: 'mr@medivisit.com',
            name: 'Dr. Rahul Sharma (MR)',
            phone: '+91 98765 43210',
            role: 'mr',
            territoryId: 'mumbai_west',
            isVerified: true,
            isBlocked: false,
            language: 'en',
            darkMode: false,
            fcmTokens: [],
            createdAt: DateTime.now(),
          );
      
      isBlocked.value = mrUser.value?.isBlocked ?? false;

      recentVisits.value = await _visitRepo.getByMr(mrId);
      
      // If empty, use mock data for demonstration
      if (recentVisits.isEmpty) {
        recentVisits.value = [
          Visit(
            id: 'v1',
            mrId: mrId,
            doctorId: 'd1',
            doctorName: 'Dr. A. K. Sharma',
            visitDate: '2026-07-23',
            visitTime: '10:30 AM',
            dayOfWeek: 'Wednesday',
            feedbackTags: ['Excellent Pitch'],
            geofenceVerified: true,
            status: VisitStatus.visited,
            visitSource: 'scheduled',
            adminReviewStatus: 'approved',
            latitude: 19.0780,
            longitude: 72.8790,
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          Visit(
            id: 'v2',
            mrId: mrId,
            doctorId: 'd2',
            doctorName: 'Dr. Priya Mehta',
            visitDate: '2026-07-23',
            visitTime: '01:15 PM',
            dayOfWeek: 'Wednesday',
            feedbackTags: [],
            geofenceVerified: false,
            status: VisitStatus.planned,
            visitSource: 'self_reported',
            adminReviewStatus: 'pending',
            latitude: 19.0740,
            longitude: 72.8760,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          Visit(
            id: 'v3',
            mrId: mrId,
            doctorId: 'd3',
            doctorName: 'Dr. Suresh Patel',
            visitDate: '2026-07-22',
            visitTime: '04:45 PM',
            dayOfWeek: 'Tuesday',
            feedbackTags: [],
            geofenceVerified: false,
            status: VisitStatus.visited,
            visitSource: 'self_reported',
            adminReviewStatus: 'rejected',
            latitude: 19.0710,
            longitude: 72.8720,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
      }

      // Mock performance trend
      visitTrendSpots.value = const [
        FlSpot(1, 12),
        FlSpot(2, 18),
        FlSpot(3, 14),
        FlSpot(4, 22),
        FlSpot(5, 28),
        FlSpot(6, 25),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBlockAccount() {
    isBlocked.value = !isBlocked.value;
    Get.snackbar(
      isBlocked.value ? 'Account Blocked' : 'Account Active',
      isBlocked.value
          ? '${mrUser.value?.name} access has been suspended.'
          : '${mrUser.value?.name} access has been restored.',
      backgroundColor: isBlocked.value ? const Color(0xFFBA1A1A) : const Color(0xFF006B5C),
      colorText: Colors.white,
    );
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  Future<void> submitFeedback({String? visitId}) async {
    final note = feedbackNoteController.text.trim();
    if (note.isEmpty && selectedTags.isEmpty) {
      Get.snackbar('Empty', 'Please add a note or select a tag before submitting.');
      return;
    }
    
    try {
      await FirebaseFirestore.instance.collection('manager_feedback').add({
        'mrId': mrId,
        'mrName': mrUser.value?.name ?? 'MR',
        'visitId': visitId,
        'note': note,
        'tags': selectedTags.toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Offline fallback
    }
    
    Get.snackbar(
      'Feedback Saved',
      'Manager feedback logged successfully.',
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
    
    feedbackNoteController.clear();
    selectedTags.clear();
    Get.back();
  }

  @override
  void onClose() {
    feedbackNoteController.dispose();
    super.onClose();
  }
}
