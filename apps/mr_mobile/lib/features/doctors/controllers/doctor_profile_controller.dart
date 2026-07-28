import 'package:get/get.dart';
import 'package:core/core.dart';
import '../../../app/routes.dart';

class DoctorProfileController extends GetxController {
  final DoctorRepository _doctorRepo = Get.find<DoctorRepository>();
  
  final Rx<Doctor?> doctor = Rx<Doctor?>(null);
  final RxBool isLoading = true.obs;
  
  late String doctorId;

  @override
  void onInit() {
    super.onInit();
    doctorId = Get.arguments as String;
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    try {
      isLoading.value = true;
      final doc = await _doctorRepo.getById(doctorId);
      if (doc != null) {
        doctor.value = doc;
      } else {
        Get.snackbar('Error', 'Doctor not found');
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load doctor details: $e');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  void startVisit() {
    // This will navigate to Confirm Visit Location screen, passing the doctor info
    Get.toNamed(AppRoutes.confirmVisit, arguments: doctor.value);
  }
}
