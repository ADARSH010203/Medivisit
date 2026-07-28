import 'dart:math';

class GeofenceService {
  // Returns distance in meters between two coordinates
  static double calculateDistanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + 
            c(lat1 * p) * c(lat2 * p) * 
            (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R; R = 6371 km
  }

  // Fast client-side check
  static bool isWithinGeofence(double userLat, double userLon, double targetLat, double targetLon, int radiusInMeters) {
    final distance = calculateDistanceInMeters(userLat, userLon, targetLat, targetLon);
    return distance <= radiusInMeters;
  }
}
