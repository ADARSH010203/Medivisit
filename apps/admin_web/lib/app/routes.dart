import 'package:get/get.dart';
import 'middleware/auth_middleware.dart';
import '../features/shell/views/shell.dart';
import '../features/doctors/views/admin_doctor_management_screen.dart';
import '../features/products/views/admin_product_management_screen.dart';
import '../features/mrs/views/admin_mr_management_screen.dart';
import '../features/auth/views/admin_login_screen.dart';
import '../features/dashboard/views/admin_dashboard_screen.dart';
import '../features/mrs/views/mr_verification_screen.dart';
import '../features/reports/views/attendance_report_screen.dart';
import '../features/leave/views/leave_approval_screen.dart';
import '../features/leave/controllers/leave_approval_controller.dart';
import '../features/notifications/views/notification_sender_screen.dart';
import '../features/notifications/controllers/notification_sender_controller.dart';
import '../features/reports/views/leaderboard_report_screen.dart';
import '../features/reports/controllers/leaderboard_report_controller.dart';
import '../features/mrs/views/mr_detail_tracking_screen.dart';
import '../features/mrs/controllers/mr_detail_tracking_controller.dart';
import '../features/tracking/views/live_tracking_screen.dart';
import '../features/expenses/views/admin_expense_screen.dart';
import '../features/reports/views/reports_dashboard_screen.dart';
import '../features/territory/views/territory_management_screen.dart';
import '../features/settings/views/admin_settings_screen.dart';
import '../features/visits/views/self_reported_visits_screen.dart';

class AppRoutes {
  static const String login = '/admin/login';
  static const String dashboard = '/admin/dashboard';
  static const String doctors = '/admin/doctors';
  static const String products = '/admin/products';
  static const String mrs = '/admin/mrs';
  static const String mrVerification = '/admin/mrs/verification';
  static const String attendanceReport = '/admin/reports/attendance';
  static const String leaveApprovals = '/admin/leave';
  static const String notifications = '/admin/notifications';
  static const String leaderboardReport = '/admin/reports/leaderboard';
  static const String reportsDashboard = '/admin/reports/dashboard';
  static const String mrDetail = '/admin/mrs/detail';
  static const String tracking = '/admin/tracking';
  static const String expenses = '/admin/expenses';
  static const String territories = '/admin/territories';
  static const String settings = '/admin/settings';
  static const String selfReportedVisits = '/admin/self-reported-visits';

  static final pages = [
    GetPage(
      name: login,
      page: () => const AdminLoginScreen(),
    ),
    GetPage(
      name: dashboard,
      page: () => const AdminShell(child: AdminDashboardScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: doctors,
      page: () => const AdminShell(child: AdminDoctorManagementScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: products,
      page: () => const AdminShell(child: AdminProductManagementScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: mrs,
      page: () => const AdminShell(child: AdminMrManagementScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: mrVerification,
      page: () => const AdminShell(child: MrVerificationScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: attendanceReport,
      page: () => const AdminShell(child: AttendanceReportScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: leaveApprovals,
      page: () => const AdminShell(child: LeaveApprovalScreen()),
      binding: BindingsBuilder(() {
        Get.put(LeaveApprovalController());
      }),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: notifications,
      page: () => const AdminShell(child: NotificationSenderScreen()),
      binding: BindingsBuilder(() {
        Get.put(NotificationSenderController());
      }),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: leaderboardReport,
      page: () => const AdminShell(child: LeaderboardReportScreen()),
      binding: BindingsBuilder(() {
        Get.put(LeaderboardReportController());
      }),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: mrDetail,
      page: () => const AdminShell(child: MrDetailTrackingScreen()),
      binding: BindingsBuilder(() {
        Get.put(MrDetailTrackingController());
      }),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: tracking,
      page: () => const AdminShell(child: LiveTrackingScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: expenses,
      page: () => const AdminShell(child: AdminExpenseScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: reportsDashboard,
      page: () => const AdminShell(child: ReportsDashboardScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: territories,
      page: () => const AdminShell(child: TerritoryManagementScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: settings,
      page: () => const AdminShell(child: AdminSettingsScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: selfReportedVisits,
      page: () => const AdminShell(child: SelfReportedVisitsScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
  ];
}
