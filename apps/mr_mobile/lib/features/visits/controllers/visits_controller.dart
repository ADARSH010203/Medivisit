import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:intl/intl.dart';

class VisitsController extends GetxController {
  final VisitRepository _visitRepo = Get.find<VisitRepository>();

  final RxList<Visit> currentVisits = <Visit>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVisitsForSelectedDate();
    
    // Refresh when date changes
    ever(selectedDate, (_) => _loadVisitsForSelectedDate());
  }

  void _loadVisitsForSelectedDate() async {
    isLoading.value = true;
    const userId = 'current_user_id_placeholder'; // In real app, get from AuthController
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    
    _visitRepo.streamTodaysVisits(userId, dateStr).listen((visits) {
      currentVisits.value = visits;
      isLoading.value = false;
    });
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  Future<void> confirmVisitLocation(Visit visit, String? notes, bool isException) async {
    isLoading.value = true;
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos == null) throw Exception("Could not get location");

      final updatedVisit = visit.copyWith(
        status: VisitStatus.visited,
        locationTimestamp: DateTime.now(),
        latitude: pos.latitude,
        longitude: pos.longitude,
        notes: notes ?? visit.notes,
        outOfGeofenceReason: isException ? 'Geofence Exception' : null,
        geofenceVerified: !isException,
      );
      
      await _visitRepo.update(updatedVisit.id, updatedVisit.toFirestore());
      Get.back(result: true); // Return success to previous screen
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
