import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class DoctorFilterController extends GetxController {
  final DoctorRepository _doctorRepo = Get.find<DoctorRepository>();
  
  final Rx<DoctorFilterModel> filter = const DoctorFilterModel().obs;
  final RxList<Doctor> allDoctors = <Doctor>[].obs;
  final RxList<Doctor> filteredDoctors = <Doctor>[].obs;
  
  final Rxn<LatLng> currentLocation = Rxn<LatLng>();
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    // Debounce slider or rapid filter changes to ensure smooth UI performance
    debounce(filter, (_) => applyFilters(), time: const Duration(milliseconds: 300));
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      // 1. Get location
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentLocation.value = LatLng(position.latitude, position.longitude);

      // 2. Load all active doctors
      final docs = await _doctorRepo.getAll();
      allDoctors.value = docs.where((d) => d.isActive).toList();

      // 3. Apply initial filters
      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load doctors: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateFilter(DoctorFilterModel newFilter) {
    filter.value = newFilter;
  }

  void applyFilters() {
    if (currentLocation.value == null) return;
    
    final currentFilter = filter.value;
    final currentPos = currentLocation.value!;
    const distanceCalculator = Distance();

    List<Doctor> result = allDoctors.where((doc) {
      // 1. Specialty Filter
      if (currentFilter.specialties.isNotEmpty && !currentFilter.specialties.contains(doc.specialty)) {
        return false;
      }

      // 2. Rating Filter
      if (doc.engagementRating < currentFilter.minRating) {
        return false;
      }

      // 3. Availability
      if (currentFilter.availableToday) {
        final today = _getTodayString();
        if (!doc.availableDays.contains(today)) return false;
      }

      // 4. High Priority
      if (currentFilter.highPriorityOnly && !doc.isHighPriority) {
        return false;
      }

      // 5. Distance Filter
      final docLoc = LatLng(doc.clinicLocation.latitude, doc.clinicLocation.longitude);
      final distKm = distanceCalculator.as(LengthUnit.Kilometer, currentPos, docLoc);
      if (distKm > currentFilter.distanceKm) {
        return false;
      }

      return true;
    }).toList();

    // 6. Sorting
    result.sort((a, b) {
      switch (currentFilter.sortBy) {
        case SortOption.nearest:
          final distA = distanceCalculator.as(LengthUnit.Meter, currentPos, LatLng(a.clinicLocation.latitude, a.clinicLocation.longitude));
          final distB = distanceCalculator.as(LengthUnit.Meter, currentPos, LatLng(b.clinicLocation.latitude, b.clinicLocation.longitude));
          return distA.compareTo(distB);
        case SortOption.highestRated:
          return b.engagementRating.compareTo(a.engagementRating);
        case SortOption.mostVisited:
          return b.totalVisitsByMrs.compareTo(a.totalVisitsByMrs);
        case SortOption.highPriorityFirst:
          if (a.isHighPriority && !b.isHighPriority) return -1;
          if (!a.isHighPriority && b.isHighPriority) return 1;
          return 0; // fallback to nearest for same priority
      }
    });

    filteredDoctors.value = result;
  }

  String _getTodayString() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Mon';
    }
  }
}
