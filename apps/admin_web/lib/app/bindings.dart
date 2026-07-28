import 'package:get/get.dart';
import 'package:core/core.dart';
import '../features/auth/controllers/admin_auth_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<AuthRepository>(() => FirebaseAuthRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => FirebaseUserRepository(), fenix: true);
    Get.lazyPut<DoctorRepository>(() => FirebaseDoctorRepository(), fenix: true);
    Get.lazyPut<ProductRepository>(() => FirebaseProductRepository(), fenix: true);
    Get.lazyPut<VisitRepository>(() => FirebaseVisitRepository(), fenix: true);
    Get.lazyPut<LeaveRepository>(() => FirebaseLeaveRepository(), fenix: true);
    Get.lazyPut<AttendanceRepository>(() => FirebaseAttendanceRepository(), fenix: true);
    Get.lazyPut<NotificationRepository>(() => FirebaseNotificationRepository(), fenix: true);
    Get.lazyPut<LeaderboardRepository>(() => FirebaseLeaderboardRepository(), fenix: true);
    Get.lazyPut<TrackingRepository>(() => FirebaseTrackingRepository(), fenix: true);
    Get.lazyPut<ExpenseRepository>(() => FirebaseExpenseRepository(), fenix: true);

    // Services
    Get.lazyPut<AuthService>(() => AuthService(Get.find<AuthRepository>(), Get.find<UserRepository>()), fenix: true);

    // Controllers
    Get.put<AdminAuthController>(AdminAuthController(Get.find<AuthService>()), permanent: true);
  }
}
