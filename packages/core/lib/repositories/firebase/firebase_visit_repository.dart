import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/visit.dart';
import '../visit_repository.dart';

import 'package:get/get.dart';
import '../../services/offline_sync_service.dart';

class FirebaseVisitRepository implements VisitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseVisitRepository() {
    // Attempt to register handler if service exists
    if (Get.isRegistered<OfflineSyncService>()) {
      Get.find<OfflineSyncService>().registerHandler('create_visit', (payload) async {
        final id = payload.remove('_doc_id') as String?;
        if (id == null || id.isEmpty) return;
        await _firestore.collection('visits').doc(id).set(payload);
      });
    }
  }

  @override
  Future<void> create(Visit visit) async {
    if (Get.isRegistered<OfflineSyncService>()) {
      final payload = visit.toFirestore();
      payload['id'] = visit.id;
      await Get.find<OfflineSyncService>().queueAction('create_visit', payload);
    } else {
      await _firestore.collection('visits').doc(visit.id).set(visit.toFirestore());
    }
  }

  @override
  Future<List<Visit>> getByMr(String mrId) async {
    final snapshot = await _firestore
        .collection('visits')
        .where('mr_id', isEqualTo: mrId)
        .orderBy('visit_date', descending: true)
        .get();
    return snapshot.docs.map((doc) => Visit.fromFirestore(doc)).toList();
  }

  @override
  Future<List<Visit>> getByDoctor(String doctorId) async {
    final snapshot = await _firestore
        .collection('visits')
        .where('doctor_id', isEqualTo: doctorId)
        .orderBy('visit_date', descending: true)
        .get();
    return snapshot.docs.map((doc) => Visit.fromFirestore(doc)).toList();
  }

  @override
  Future<List<Visit>> getByDate(String mrId, String date) async {
    final snapshot = await _firestore
        .collection('visits')
        .where('mr_id', isEqualTo: mrId)
        .where('visit_date', isEqualTo: date)
        .get();
    return snapshot.docs.map((doc) => Visit.fromFirestore(doc)).toList();
  }

  @override
  Future<Visit?> getById(String id) async {
    final doc = await _firestore.collection('visits').doc(id).get();
    if (doc.exists) {
      return Visit.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) {
    return _firestore.collection('visits').doc(id).update(data);
  }

  @override
  Stream<List<Visit>> streamTodaysVisits(String mrId, String date) {
    return _firestore
        .collection('visits')
        .where('mr_id', isEqualTo: mrId)
        .where('visit_date', isEqualTo: date)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Visit.fromFirestore(doc)).toList());
  }

  @override
  Future<List<Visit>> getVisitHistory(String mrId, {int limit = 50}) async {
    final snapshot = await _firestore
        .collection('visits')
        .where('mr_id', isEqualTo: mrId)
        .orderBy('visit_date', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => Visit.fromFirestore(doc)).toList();
  }
}
