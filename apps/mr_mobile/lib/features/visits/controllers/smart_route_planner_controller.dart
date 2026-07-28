import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../auth/controllers/auth_controller.dart';

class SmartRoutePlannerController extends GetxController {
  final VisitRepository _visitRepo = Get.find<VisitRepository>();
  final DoctorRepository _doctorRepo = Get.find<DoctorRepository>();
  final AuthController _authController = Get.find<AuthController>();
  
  final RxList<Doctor> optimizedRoute = <Doctor>[].obs;
  final RxBool isLoading = true.obs;
  final Rxn<LatLng> currentLocation = Rxn<LatLng>();
  
  late RouteOptimizer _optimizer;

  @override
  void onInit() {
    super.onInit();
    _optimizer = RouteOptimizer(HeuristicPriorityScorer());
    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    isLoading.value = true;
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentLocation.value = LatLng(position.latitude, position.longitude);
      final start = currentLocation.value!;

      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final todaysVisits = await _visitRepo.getByDate(user.uid, todayStr);
      
      if (todaysVisits.isEmpty) {
        optimizedRoute.clear();
        return;
      }

      final doctorIds = todaysVisits.map((v) => v.doctorId).toSet().toList();
      final List<Doctor> doctorsToVisit = [];
      
      for (final id in doctorIds) {
        final doc = await _doctorRepo.getById(id);
        if (doc != null) {
          doctorsToVisit.add(doc);
        }
      }
      
      if (doctorsToVisit.isEmpty) {
        optimizedRoute.clear();
        return;
      }

      final Map<String, List<Visit>> histories = {};
      for (final doc in doctorsToVisit) {
        final history = await _visitRepo.getByDoctor(doc.id);
        histories[doc.id] = history;
      }

      final route = await _optimizer.optimizeRoute(
        startLocation: start,
        doctors: doctorsToVisit,
        visitHistories: histories,
      );

      optimizedRoute.value = route;
    } catch (e) {
      print('Route optimization failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getDistanceTo(Doctor doctor) {
    if (currentLocation.value == null) return 'N/A';
    
    final dist = const Distance().as(
      LengthUnit.Kilometer,
      currentLocation.value!,
      LatLng(doctor.clinicLocation.latitude, doctor.clinicLocation.longitude),
    );
    return '${dist.toStringAsFixed(1)}km';
  }

  Future<void> startNavigation(Doctor doctor) async {
    try {
      // In a real app we would use url_launcher:
      // final url = 'https://www.google.com/maps/dir/?api=1&destination=${doctor.clinicLocation.latitude},${doctor.clinicLocation.longitude}';
      // await launchUrl(Uri.parse(url));
      Get.snackbar('Navigation', 'Starting navigation to ${doctor.name}...');
    } catch (e) {
      Get.snackbar('Error', 'Could not open maps: $e');
    }
  }
}
