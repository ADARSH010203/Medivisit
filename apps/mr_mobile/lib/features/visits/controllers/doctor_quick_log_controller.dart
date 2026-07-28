import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:intl/intl.dart';

class DoctorQuickLogController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final DoctorRepository _doctorRepo = Get.find<DoctorRepository>();
  final VisitRepository _visitRepo = Get.find<VisitRepository>();

  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool isLocating = false.obs;

  // Search logic
  final RxList<Doctor> allDoctors = <Doctor>[].obs;
  final RxList<Doctor> filteredDoctors = <Doctor>[].obs;
  final Rx<Doctor?> selectedDoctor = Rx<Doctor?>(null);
  
  final TextEditingController searchController = TextEditingController();

  // Add new doctor form
  final RxBool isAddingNewDoctor = false.obs;
  final TextEditingController doctorNameController = TextEditingController();
  final RxString selectedSpecialty = 'General Physician'.obs;
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController clinicAddressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final List<String> specialties = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Endocrinologist',
    'Gastroenterologist',
    'Neurologist',
    'Pediatrician',
    'Psychiatrist',
    'Orthopedist',
    'Gynecologist',
  ];

  // GPS
  final Rx<LatLng?> gpsLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> pinLocation = Rx<LatLng?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _doctorRepo.getAll();
      allDoctors.assignAll(doctors);
      filteredDoctors.assignAll(doctors);
    } catch (e) {
      debugPrint('Error loading doctors: $e');
    }
  }

  void searchDoctors(String query) {
    if (query.isEmpty) {
      filteredDoctors.assignAll(allDoctors);
    } else {
      filteredDoctors.assignAll(allDoctors.where((d) => 
        d.name.toLowerCase().contains(query.toLowerCase()) || 
        d.clinicName.toLowerCase().contains(query.toLowerCase())
      ));
    }
  }

  void selectDoctor(Doctor doctor) {
    selectedDoctor.value = doctor;
    isAddingNewDoctor.value = false;
    searchController.text = doctor.name;
    filteredDoctors.clear();
  }

  void startAddingNewDoctor() {
    isAddingNewDoctor.value = true;
    selectedDoctor.value = null;
    doctorNameController.text = searchController.text;
  }

  Future<void> captureLocation() async {
    isLocating.value = true;
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null) {
        gpsLocation.value = LatLng(pos.latitude, pos.longitude);
        pinLocation.value = gpsLocation.value;
      }
    } catch (e) {
      Get.snackbar('Location Error', e.toString());
    } finally {
      isLocating.value = false;
    }
  }

  void updatePinLocation(LatLng newLocation) {
    if (gpsLocation.value == null) {
      pinLocation.value = newLocation;
      return;
    }

    final distance = _calculateDistance(
      gpsLocation.value!.latitude, gpsLocation.value!.longitude,
      newLocation.latitude, newLocation.longitude
    );

    if (distance > 50) {
      Get.defaultDialog(
        title: 'Distance Warning',
        middleText: 'You are placing the pin more than 50 meters away from your current GPS location. Are you sure this is the correct clinic location?',
        textConfirm: 'Yes, I am sure',
        textCancel: 'Cancel',
        confirmTextColor: Colors.white,
        buttonColor: AppColors.error,
        onConfirm: () {
          pinLocation.value = newLocation;
          Get.back();
        },
      );
    } else {
      pinLocation.value = newLocation;
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - 
        (lat2 - lat1 * p).abs() / 2 +
        (lat1 * p).abs() * (lat2 * p).abs() * (1 - (lon2 - lon1 * p).abs()) / 2;
    return 12742 * (a * a).abs() * 1000;
  }

  Future<void> submitQuickVisit() async {
    if (pinLocation.value == null) {
      Get.snackbar('Error', 'Please capture or drop a pin for the location.');
      return;
    }

    if (isAddingNewDoctor.value && !formKey.currentState!.validate()) {
      return;
    }

    if (!isAddingNewDoctor.value && selectedDoctor.value == null) {
      Get.snackbar('Error', 'Please select a doctor or add a new one.');
      return;
    }

    isLoading.value = true;
    try {
      final user = _authController.currentUser.value;
      if (user == null) throw Exception('User not logged in');

      Doctor docToVisit;
      
      if (isAddingNewDoctor.value) {
        docToVisit = Doctor(
          id: const Uuid().v4(),
          name: doctorNameController.text.trim(),
          specialty: selectedSpecialty.value,
          qualification: 'Unknown',
          clinicName: clinicNameController.text.trim(),
          clinicAddress: clinicAddressController.text.trim(),
          clinicLocation: GeoPoint(pinLocation.value!.latitude, pinLocation.value!.longitude),
          geofenceRadiusM: 150,
          phone: phoneController.text.trim(),
          bio: notesController.text.trim(),
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
          timingStart: '09:00',
          timingEnd: '17:00',
          isActive: true,
          isHighPriority: false,
          totalVisits: 0,
          source: 'mr_reported',
          reportedByMr: user.uid,
          createdAt: DateTime.now(),
        );
        // Note: we don't save the doctor to doctors collection yet, wait for admin approval!
      } else {
        docToVisit = selectedDoctor.value!;
      }

      final now = DateTime.now();
      
      final visit = Visit(
        id: const Uuid().v4(),
        mrId: user.uid,
        doctorId: docToVisit.id, // For new doctor, this is the generated ID
        doctorName: docToVisit.name,
        visitDate: DateFormat('yyyy-MM-dd').format(now),
        visitTime: DateFormat('HH:mm').format(now),
        dayOfWeek: DateFormat('EEEE').format(now),
        feedbackTags: [],
        geofenceVerified: false,
        status: VisitStatus.visited,
        visitSource: 'self_reported',
        adminReviewStatus: 'pending',
        latitude: pinLocation.value!.latitude,
        longitude: pinLocation.value!.longitude,
        locationTimestamp: now,
        notes: isAddingNewDoctor.value 
            ? 'NEW DOCTOR: ${docToVisit.clinicName}, ${docToVisit.clinicAddress}, ${docToVisit.specialty}' 
            : notesController.text.trim(),
        createdAt: now,
      );

      await _visitRepo.create(visit);
      
      // Trigger Supabase edge function
      try {
        await SupabaseFunctionService.notifyAdminSelfReport(visit.id);
      } catch (e) {
        debugPrint('Notification failed: $e');
        // Continue even if notification fails, since visit is saved.
      }

      Get.back();
      Get.snackbar(
        'Visit Submitted', 
        'Your self-reported visit has been submitted for admin approval.',
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );

    } catch (e) {
      debugPrint('Quick Log Error: $e');
      Get.snackbar('Submission Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    doctorNameController.dispose();
    clinicNameController.dispose();
    clinicAddressController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
