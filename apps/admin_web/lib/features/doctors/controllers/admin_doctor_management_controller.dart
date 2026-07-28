import 'package:get/get.dart';

class AdminDoctorManagementController extends GetxController {
  final isLoading = false.obs;
  
  // Mock data
  final doctors = <Map<String, dynamic>>[
    {
      'id': '1',
      'name': 'Dr. Emily Chen',
      'specialty': 'Cardiology',
      'clinic': 'Heart Center',
      'status': 'Active',
    },
    {
      'id': '2',
      'name': 'Dr. Anil Patel',
      'specialty': 'Neurology',
      'clinic': 'Brain Health Clinic',
      'status': 'Active',
    }
  ].obs;

  void addDoctor() {
    // Show add doctor dialog
  }

  void editDoctor(String id) {
    // Show edit doctor dialog
  }

  void deleteDoctor(String id) {
    // Confirm and delete doctor
  }
}
