enum MapLayerType { standard, satellite, terrain }
enum SortOption { nearest, highestRated, mostVisited, highPriorityFirst }

class DoctorFilterModel {
  final MapLayerType mapLayer;
  final List<String> specialties;
  final double minRating;
  final double distanceKm;
  final bool availableToday;
  final bool highPriorityOnly;
  final SortOption sortBy;

  const DoctorFilterModel({
    this.mapLayer = MapLayerType.standard,
    this.specialties = const [],
    this.minRating = 0.0,
    this.distanceKm = 10.0,
    this.availableToday = false,
    this.highPriorityOnly = false,
    this.sortBy = SortOption.nearest,
  });

  DoctorFilterModel copyWith({
    MapLayerType? mapLayer,
    List<String>? specialties,
    double? minRating,
    double? distanceKm,
    bool? availableToday,
    bool? highPriorityOnly,
    SortOption? sortBy,
  }) {
    return DoctorFilterModel(
      mapLayer: mapLayer ?? this.mapLayer,
      specialties: specialties ?? this.specialties,
      minRating: minRating ?? this.minRating,
      distanceKm: distanceKm ?? this.distanceKm,
      availableToday: availableToday ?? this.availableToday,
      highPriorityOnly: highPriorityOnly ?? this.highPriorityOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
