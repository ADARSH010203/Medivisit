import 'package:get/get.dart';
import 'middleware/auth_middleware.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/register_screen.dart';
import '../features/auth/views/onboarding_screen.dart';
import '../features/auth/views/pending_verification_screen.dart';
import '../features/dashboard/views/dashboard_screen.dart';
import '../features/visits/views/visits_screen.dart';
import '../features/visits/views/confirm_location_screen.dart';
import '../features/visits/views/visit_success_screen.dart';
import '../features/visits/views/doctor_rating_screen.dart';
import '../features/doctors/views/doctor_profile_screen.dart';
import '../features/visits/views/visit_history_screen.dart';
import '../features/visits/views/visit_audit_screen.dart';
import '../features/visits/views/doctor_quick_log_screen.dart';
import '../features/products/views/product_catalog_screen.dart';
import '../features/products/views/product_detail_screen.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/profile/views/edit_profile_screen.dart';
import '../features/attendance/views/mark_attendance_screen.dart';
import '../features/attendance/views/attendance_history_screen.dart';
import '../features/leave/views/leave_request_screen.dart';
import '../features/leave/views/leave_history_screen.dart';
import '../features/leave/controllers/leave_request_controller.dart';
import '../features/leave/controllers/leave_history_controller.dart';

import '../features/notifications/views/notifications_screen.dart';
import '../features/notifications/controllers/notifications_controller.dart';
import '../features/gamification/views/achievements_screen.dart';
import '../features/gamification/controllers/achievements_controller.dart';
import '../features/gamification/views/leaderboard_screen.dart';
import '../features/gamification/controllers/leaderboard_controller.dart';
import '../features/gamification/views/performance_screen.dart' as gamification;
import '../features/gamification/controllers/performance_controller.dart';
import '../features/visits/views/smart_route_planner_screen.dart';
import '../features/expenses/views/expense_submission_screen.dart';
import '../features/expenses/views/expense_history_screen.dart';
import '../features/discovery/views/discovery_map_screen.dart';

import '../features/profile/views/security_settings_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String pendingVerification = '/pending-verification';
  static const String dashboard = '/dashboard';
  static const String visits = '/visits';
  static const String catalog = '/catalog';
  static const String profile = '/profile';
  static const String doctorProfile = '/doctor';
  static const String confirmVisit = '/confirm-visit';
  static const String visitSuccess = '/visit-success';
  static const String doctorRating = '/doctor-rating';
  static const String visitHistory = '/visit-history';
  static const String visitAudit = '/visit-audit';
  static const String productDetail = '/product-detail';
  static const String editProfile = '/edit-profile';
  static const String markAttendance = '/attendance';
  static const String attendanceHistory = '/attendance/history';
  static const String leaveRequest = '/leave/request';
  static const String leaveHistory = '/leave/history';

  static const String notifications = '/notifications';
  static const String achievements = '/achievements';
  static const String leaderboard = '/gamification/leaderboard';
  static const String performance = '/gamification/performance';
  static const String smartRoutePlanner = '/visits/smart_route_planner';
  static const String expenseSubmission = '/expenses/submit';
  static const String expenseHistory = '/expenses/history';
  static const String quickLogVisit = '/visits/quick-log';
  static const String discoveryMap = '/discovery/map';
  static const String securitySettings = '/profile/security';

  static final pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: pendingVerification,
      page: () => const PendingVerificationScreen(),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: visits,
      page: () => const VisitsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: visitHistory,
      page: () => const VisitHistoryScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: visitAudit,
      page: () => const VisitAuditScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: catalog,
      page: () => const ProductCatalogScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: productDetail,
      page: () => const ProductDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: editProfile,
      page: () => const EditProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: doctorProfile,
      page: () => const DoctorProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: confirmVisit,
      page: () => const ConfirmLocationScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: visitSuccess,
      page: () => const VisitSuccessScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: doctorRating,
      page: () => const DoctorRatingScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: markAttendance,
      page: () => const MarkAttendanceScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: attendanceHistory,
      page: () => const AttendanceHistoryScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: leaveRequest,
      page: () => const LeaveRequestScreen(),
      binding: BindingsBuilder(() {
        Get.put(LeaveRequestController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: leaveHistory,
      page: () => const LeaveHistoryScreen(),
      binding: BindingsBuilder(() {
        Get.put(LeaveHistoryController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      binding: BindingsBuilder(() {
        Get.put(NotificationsController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: achievements,
      page: () => const AchievementsScreen(),
      binding: BindingsBuilder(() {
        Get.put(AchievementsController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: leaderboard,
      page: () => const LeaderboardScreen(),
      binding: BindingsBuilder(() {
        Get.put(LeaderboardController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: performance,
      page: () => const gamification.PerformanceScreen(),
      binding: BindingsBuilder(() {
        Get.put(PerformanceController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: smartRoutePlanner,
      page: () => const SmartRoutePlannerScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: expenseSubmission,
      page: () => const ExpenseSubmissionScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: expenseHistory,
      page: () => const ExpenseHistoryScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: quickLogVisit,
      page: () => const DoctorQuickLogScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: discoveryMap,
      page: () => const DiscoveryMapScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: securitySettings,
      page: () => const SecuritySettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
