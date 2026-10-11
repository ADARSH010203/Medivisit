import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/doctor.dart';
import '../models/visit.dart';

abstract class DoctorPriorityScorer {
  Future<double> scoreDoctor(Doctor doctor, List<Visit> history);
}

class HeuristicPriorityScorer implements DoctorPriorityScorer {
  @override
  Future<double> scoreDoctor(Doctor doctor, List<Visit> history) async {
    double score = 50.0;
    
    if (history.isEmpty) {
      score += 30.0;
    } else {
      final lastVisit = history.first;
      final lastDate = DateTime.tryParse(lastVisit.visitDate) ?? DateTime.now();
      final daysSinceLast = DateTime.now().difference(lastDate).inDays;
      if (daysSinceLast > 30) {
        score += 20.0;
      } else if (daysSinceLast < 7) {
        score -= 10.0;
      }
    }
    
    return score;
  }
}

class RouteOptimizer {
  final DoctorPriorityScorer scorer;
  
  RouteOptimizer(this.scorer);

  double _haversineDistance(LatLng pos1, LatLng pos2) {
    const double r = 6371e3; // metres
    final phi1 = pos1.latitude * math.pi / 180;
    final phi2 = pos2.latitude * math.pi / 180;
    final deltaPhi = (pos2.latitude - pos1.latitude) * math.pi / 180;
    final deltaLambda = (pos2.longitude - pos1.longitude) * math.pi / 180;

    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
        math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return r * c;
  }

  Future<List<Doctor>> optimizeRoute({
    required LatLng startLocation,
    required List<Doctor> doctors,
    required Map<String, List<Visit>> visitHistories,
  }) async {
    if (doctors.isEmpty) return [];

    final unvisited = List<Doctor>.from(doctors);
    final List<Doctor> route = [];
    LatLng currentLocation = startLocation;

    while (unvisited.isNotEmpty) {
      Doctor? bestNext;
      double bestScore = double.negativeInfinity;

      for (final doc in unvisited) {
        final docLocation = LatLng(doc.clinicLocation.latitude, doc.clinicLocation.longitude);
        final distanceInMeters = _haversineDistance(currentLocation, docLocation);
        
        final distanceScore = math.max(0.0, 100.0 - (distanceInMeters / 500.0));
        
        final history = visitHistories[doc.id] ?? [];
        final priorityScore = await scorer.scoreDoctor(doc, history);

        final combinedScore = distanceScore + priorityScore;

        if (combinedScore > bestScore) {
          bestScore = combinedScore;
          bestNext = doc;
        }
      }

      bestNext ??= unvisited.first;

      route.add(bestNext);
      unvisited.remove(bestNext);
      
      currentLocation = LatLng(bestNext.clinicLocation.latitude, bestNext.clinicLocation.longitude);
    }

    return route;
  }
}
