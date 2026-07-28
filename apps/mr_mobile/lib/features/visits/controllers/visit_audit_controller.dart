import 'package:get/get.dart';

class VisitAuditController extends GetxController {
  final isLoading = false.obs;
  
  // Mock data
  final visitDetails = {
    'id': '1',
    'doctorName': 'Dr. Emily Chen',
    'date': 'Yesterday',
    'time': '11:15 AM',
    'duration': '15 mins',
    'status': 'Verified',
    'rating': 5,
    'locationMatch': 'Yes (12m variance)',
    'notes': 'Discussed new cardiology products. Doctor showed interest in sample batch.',
  }.obs;
}
