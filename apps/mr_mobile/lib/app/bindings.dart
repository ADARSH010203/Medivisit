import 'package:get/get.dart';
import 'package:core/core.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../services/location_tracker_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<AuthRepository>(() => FirebaseAuthRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => FirebaseUserRepository(), fenix: true);
    Get.lazyPut<DoctorRepository>(() => FirebaseDoctorRepository(), fenix: true);
    Get.lazyPut<VisitRepository>(() => FirebaseVisitRepository(), fenix: true);
    Get.lazyPut<ProductRepository>(() => FirebaseProductRepository(), fenix: true);
    Get.lazyPut<NotificationRepository>(() => FirebaseNotificationRepository(), fenix: true);
    Get.lazyPut<AttendanceRepository>(() => FirebaseAttendanceRepository(), fenix: true);
    Get.lazyPut<LeaveRepository>(() => FirebaseLeaveRepository(), fenix: true);
    Get.lazyPut<LeaderboardRepository>(() => FirebaseLeaderboardRepository(), fenix: true);

    // Services
    Get.lazyPut<AuthService>(() => AuthService(Get.find<AuthRepository>(), Get.find<UserRepository>()), fenix: true);

    // Controllers
    Get.put<AuthController>(AuthController(Get.find<AuthService>()), permanent: true);
    
    // Background Services (after auth is ready)
    Get.lazyPut<LocationTrackerService>(() => LocationTrackerService(), fenix: true);
  }
}
