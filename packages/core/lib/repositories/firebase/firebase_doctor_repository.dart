import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/doctor.dart';
import '../doctor_repository.dart';

class FirebaseDoctorRepository implements DoctorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Doctor>> getAll() async {
    final snapshot = await _firestore.collection('doctors').get();
    return snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
  }

  @override
  Future<Doctor?> getById(String id) async {
    final doc = await _firestore.collection('doctors').doc(id).get();
    if (doc.exists) {
      return Doctor.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> create(Doctor doctor) {
    return _firestore.collection('doctors').doc(doctor.id).set(doctor.toFirestore());
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) {
    data['updated_at'] = FieldValue.serverTimestamp();
    return _firestore.collection('doctors').doc(id).update(data);
  }

  @override
  Future<void> delete(String id) {
    return _firestore.collection('doctors').doc(id).delete();
  }

  @override
  Future<List<Doctor>> search(String query) async {
    // Simple client-side search for phase 1
    final docs = await getAll();
    final lowerQuery = query.toLowerCase();
    return docs.where((doc) {
      return doc.name.toLowerCase().contains(lowerQuery) || 
             doc.specialty.toLowerCase().contains(lowerQuery) ||
             doc.clinicName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<Doctor>> getByTerritory(String territoryId) async {
    // In Phase 1, we return all doctors or filter based on a territory field if added
    // For now returning all active doctors
    final snapshot = await _firestore.collection('doctors').where('is_active', isEqualTo: true).get();
    return snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
  }

  @override
  Stream<List<Doctor>> streamAll() {
    return _firestore.collection('doctors').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList()
    );
  }
}
