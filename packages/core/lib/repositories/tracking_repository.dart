abstract class TrackingRepository {
  /// Updates the MR's current location in the [mr_locations] collection.
  Future<void> updateLocation(String mrId, double lat, double lng, String status);
  
  /// Streams the active MR locations for the admin map.
  Stream<List<Map<String, dynamic>>> streamActiveMRLocations();
}
