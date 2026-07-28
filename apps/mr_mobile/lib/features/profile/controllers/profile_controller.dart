import 'package:get/get.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;
  
  // Mock data
  final profileData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+1 (555) 123-4567',
    'region': 'North District',
    'status': 'Active',
    'totalVisits': 142,
    'successRate': '94%',
  }.obs;

  void editProfile() {
    // Navigate to edit profile
  }
  
  void logout() {
    // Perform logout
  }
}
