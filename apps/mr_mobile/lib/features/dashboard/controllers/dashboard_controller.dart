import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:intl/intl.dart';
import '../../auth/controllers/auth_controller.dart';

/// Unified activity event for the Recent Activity feed.
class ActivityEvent {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final ActivityEventType type;

  const ActivityEvent({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });
}

enum ActivityEventType { visit, attendance, leave, expense, checkIn }

class DashboardController extends GetxController {
  // ── Repositories ─────────────────────────────────────────────────────────
  final VisitRepository _visitRepo = Get.find<VisitRepository>();
  final AttendanceRepository _attendanceRepo = Get.find<AttendanceRepository>();
  final NotificationRepository _notificationRepo =
      Get.find<NotificationRepository>();

  final AuthController authController = Get.find<AuthController>();
  final OfflineSyncService offlineSyncService = Get.find<OfflineSyncService>();

  // ── Observables ───────────────────────────────────────────────────────────
  final RxList<Visit> todaysVisits = <Visit>[].obs;
  final RxBool attendanceMarkedToday = false.obs;
  final RxInt weeklyVisitCount = 0.obs;
  final RxInt unreadNotifications = 0.obs;
  final RxList<ActivityEvent> recentActivity = <ActivityEvent>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    final user = authController.currentUser.value;
    if (user == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Stream today's visits
    todaysVisits.bindStream(_visitRepo.streamTodaysVisits(user.uid, today));

    // Stream notification badge count
    unreadNotifications
        .bindStream(_notificationRepo.streamUnreadCount(user.uid));

    // Load weekly visits + attendance in background
    _loadWeeklyData(user.uid);
    _checkTodayAttendance(user.uid);
    _loadRecentActivity(user.uid);

    // After first data load mark loading false
    Future.delayed(const Duration(milliseconds: 800), () {
      isLoading.value = false;
    });
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    final user = authController.currentUser.value;
    if (user != null) {
      await _loadWeeklyData(user.uid);
      await _checkTodayAttendance(user.uid);
      await _loadRecentActivity(user.uid);
    }
    isLoading.value = false;
  }

  Future<void> _loadWeeklyData(String uid) async {
    try {
      final now = DateTime.now();
      // Monday of this week
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      int count = 0;
      for (int i = 0; i < 7; i++) {
        final d = weekStart.add(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(d);
        final visits =
            await _visitRepo.streamTodaysVisits(uid, dateStr).first;
        count += visits
            .where((v) => v.status == VisitStatus.visited)
            .length;
      }
      weeklyVisitCount.value = count;
    } catch (_) {}
  }

  Future<void> _checkTodayAttendance(String uid) async {
    try {
      final record = await _attendanceRepo.getTodayAttendance(uid);
      attendanceMarkedToday.value = record != null;
    } catch (_) {
      attendanceMarkedToday.value = false;
    }
  }

  Future<void> _loadRecentActivity(String uid) async {
    try {
      final events = <ActivityEvent>[];

      // Pull from today's visits
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final visits = await _visitRepo.streamTodaysVisits(uid, today).first;

      for (final v in visits.take(3)) {
        if (v.status == VisitStatus.visited) {
          events.add(ActivityEvent(
            title: 'Visit completed: ${v.doctorName}',
            subtitle: 'Geofence verified',
            timestamp: v.createdAt ?? DateTime.now(),
            type: ActivityEventType.visit,
          ));
        } else if (v.status == VisitStatus.planned) {
          events.add(ActivityEvent(
            title: 'Visit planned: ${v.doctorName}',
            subtitle: v.visitTime,
            timestamp: v.createdAt ?? DateTime.now(),
            type: ActivityEventType.checkIn,
          ));
        }
      }

      // Sort by most recent first
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      recentActivity.value = events.take(5).toList();
    } catch (_) {}
  }

  // ── Computed Getters ──────────────────────────────────────────────────────
  int get completedScheduledVisitsToday =>
      todaysVisits.where((v) => v.status == VisitStatus.visited && v.visitSource == 'scheduled').length;

  int get approvedSelfReportedToday =>
      todaysVisits.where((v) => v.visitSource == 'self_reported' && v.adminReviewStatus == 'approved').length;

  int get pendingSelfReportedToday =>
      todaysVisits.where((v) => v.visitSource == 'self_reported' && v.adminReviewStatus == 'pending').length;

  int get rejectedSelfReportedToday =>
      todaysVisits.where((v) => v.visitSource == 'self_reported' && v.adminReviewStatus == 'rejected').length;

  int get completedVisitsToday =>
      completedScheduledVisitsToday + approvedSelfReportedToday;

  int get plannedVisitsToday => 
      todaysVisits.where((v) => v.visitSource == 'scheduled').length;

  double get visitProgressToday =>
      plannedVisitsToday == 0 ? (completedVisitsToday > 0 ? 1.0 : 0.0) : (completedVisitsToday / plannedVisitsToday).clamp(0.0, 1.0);

  String get greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! Ready for your visits?';
    if (hour < 17) return "Good afternoon! How's your day going?";
    return 'Good evening! Wrap up your day?';
  }

  String get greetingLabel {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get firstName {
    final name = authController.currentUser.value?.name ?? 'MR';
    return name.split(' ').first;
  }
}
