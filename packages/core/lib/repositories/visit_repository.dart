import '../models/visit.dart';

abstract class VisitRepository {
  Future<void> create(Visit visit);
  Future<List<Visit>> getByMr(String mrId);
  Future<List<Visit>> getByDoctor(String doctorId);
  Future<List<Visit>> getByDate(String mrId, String date);
  Future<Visit?> getById(String id);
  Future<void> update(String id, Map<String, dynamic> data);
  Stream<List<Visit>> streamTodaysVisits(String mrId, String date);
  Future<List<Visit>> getVisitHistory(String mrId, {int limit = 50});
}
