import 'package:get/get.dart';

class VisitHistoryController extends GetxController {
  final isLoading = false.obs;
  
  // Mock data for Phase 1
  final pastVisits = <Map<String, dynamic>>[
    {
      'id': '1',
      'doctorName': 'Dr. Emily Chen',
      'date': 'Yesterday',
      'time': '11:15 AM',
      'status': 'verified',
      'rating': 5,
    },
    {
      'id': '2',
      'doctorName': 'Dr. Anil Patel',
      'date': 'Yesterday',
      'time': '02:45 PM',
      'status': 'verified',
      'rating': 3,
    }
  ].obs;

  void viewVisitDetail(String id) {
    // Navigate to audit view
  }
}
