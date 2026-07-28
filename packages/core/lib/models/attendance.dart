class Attendance {
  final String id;
  final String mrId;
  final DateTime attendanceDate;
  final String attendanceTime;
  final double latitude;
  final double longitude;
  final DateTime locationTimestamp;
  final bool geofenceVerified;
  final String status; // present, absent, leave
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.mrId,
    required this.attendanceDate,
    required this.attendanceTime,
    required this.latitude,
    required this.longitude,
    required this.locationTimestamp,
    required this.geofenceVerified,
    required this.status,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json, String id) {
    return Attendance(
      id: id,
      mrId: json['mr_id'] ?? '',
      attendanceDate: json['attendance_date'] != null ? DateTime.parse(json['attendance_date']) : DateTime.now(),
      attendanceTime: json['attendance_time'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      locationTimestamp: json['location_timestamp'] != null ? DateTime.parse(json['location_timestamp']) : DateTime.now(),
      geofenceVerified: json['geofence_verified'] ?? false,
      status: json['status'] ?? 'absent',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mr_id': mrId,
      'attendance_date': attendanceDate.toIso8601String(),
      'attendance_time': attendanceTime,
      'latitude': latitude,
      'longitude': longitude,
      'location_timestamp': locationTimestamp.toIso8601String(),
      'geofence_verified': geofenceVerified,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
