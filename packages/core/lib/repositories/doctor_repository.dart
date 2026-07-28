import '../models/doctor.dart';

abstract class DoctorRepository {
  Future<List<Doctor>> getAll();
  Future<Doctor?> getById(String id);
  Future<void> create(Doctor doctor);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
  Future<List<Doctor>> search(String query);
  Future<List<Doctor>> getByTerritory(String territoryId);
  Stream<List<Doctor>> streamAll();
}
