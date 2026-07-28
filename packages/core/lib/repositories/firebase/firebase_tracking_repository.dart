import 'package:cloud_firestore/cloud_firestore.dart';
import '../tracking_repository.dart';

class FirebaseTrackingRepository implements TrackingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> updateLocation(String mrId, double lat, double lng, String status) async {
    final docRef = _firestore.collection('mr_locations').doc(mrId);
    
    // We update rather than set to preserve other fields if needed, 
    // or use set with merge: true.
    await docRef.set({
      'mr_id': mrId,
      'lat': lat,
      'lng': lng,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Stream<List<Map<String, dynamic>>> streamActiveMRLocations() {
    // We only fetch locations updated in the last 24 hours to avoid stale markers
    // even though TTL should clean them up.
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    
    return _firestore
        .collection('mr_locations')
        .where('updated_at', isGreaterThanOrEqualTo: yesterday)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
