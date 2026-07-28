import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  
  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });
}

class LocationService {
  static Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    } 

    return true;
  }

  static Future<LocationResult?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e) {
      debugPrint("Error getting location: $e");
      return null;
    }
  }
}

