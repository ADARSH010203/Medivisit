import '../models/attendance.dart';

abstract class AttendanceRepository {
  Future<void> markAttendance({
    required String mrId,
    required double lat,
    required double lng,
    required bool geofenceVerified,
  });

  Future<List<Attendance>> getAttendanceHistory(String mrId, DateTime month);

  Future<Attendance?> getTodayAttendance(String mrId);
}
