import 'package:cloud_firestore/cloud_firestore.dart';

enum VisitStatus { planned, visited, missed }

class Visit {
  final String id;
  final String mrId;
  final String doctorId;
  final String doctorName;
  final String visitDate;
  final String visitTime;
  final String dayOfWeek;
  final String? notes;
  final int? rating;
  final List<String> feedbackTags;
  final double? latitude;
  final double? longitude;
  final DateTime? locationTimestamp;
  final bool geofenceVerified;
  final String? outOfGeofenceReason;
  final VisitStatus status;
  final String visitSource; // 'self_reported' | 'scheduled'
  final String adminReviewStatus; // 'pending' | 'approved' | 'rejected'
  final String? adminReviewNote;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  Visit({
    required this.id,
    required this.mrId,
    required this.doctorId,
    required this.doctorName,
    required this.visitDate,
    required this.visitTime,
    required this.dayOfWeek,
    this.notes,
    this.rating,
    required this.feedbackTags,
    this.latitude,
    this.longitude,
    this.locationTimestamp,
    required this.geofenceVerified,
    this.outOfGeofenceReason,
    required this.status,
    this.visitSource = 'scheduled',
    this.adminReviewStatus = 'approved',
    this.adminReviewNote,
    this.reviewedBy,
    this.reviewedAt,
    this.createdAt,
  });

  factory Visit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    VisitStatus statusVal = VisitStatus.planned;
    switch (data['status']) {
      case 'visited':
        statusVal = VisitStatus.visited;
        break;
      case 'missed':
        statusVal = VisitStatus.missed;
        break;
    }

    return Visit(
      id: doc.id,
      mrId: data['mr_id'] ?? '',
      doctorId: data['doctor_id'] ?? '',
      doctorName: data['doctor_name'] ?? '',
      visitDate: data['visit_date'] ?? '',
      visitTime: data['visit_time'] ?? '',
      dayOfWeek: data['day_of_week'] ?? '',
      notes: data['notes'],
      rating: data['rating'],
      feedbackTags: List<String>.from(data['feedback_tags'] ?? []),
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      locationTimestamp: data['location_timestamp'] != null ? (data['location_timestamp'] as Timestamp).toDate() : null,
      geofenceVerified: data['geofence_verified'] ?? false,
      outOfGeofenceReason: data['out_of_geofence_reason'],
      status: statusVal,
      visitSource: data['visit_source'] ?? 'scheduled',
      adminReviewStatus: data['admin_review_status'] ?? 'approved',
      adminReviewNote: data['admin_review_note'],
      reviewedBy: data['reviewed_by'],
      reviewedAt: data['reviewed_at'] != null ? (data['reviewed_at'] as Timestamp).toDate() : null,
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    String statusStr = 'planned';
    switch (status) {
      case VisitStatus.visited:
        statusStr = 'visited';
        break;
      case VisitStatus.missed:
        statusStr = 'missed';
        break;
      case VisitStatus.planned:
        statusStr = 'planned';
        break;
    }

    return {
      'mr_id': mrId,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'visit_date': visitDate,
      'visit_time': visitTime,
      'day_of_week': dayOfWeek,
      if (notes != null) 'notes': notes,
      if (rating != null) 'rating': rating,
      'feedback_tags': feedbackTags,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationTimestamp != null) 'location_timestamp': Timestamp.fromDate(locationTimestamp!),
      'geofence_verified': geofenceVerified,
      if (outOfGeofenceReason != null) 'out_of_geofence_reason': outOfGeofenceReason,
      'status': statusStr,
      'visit_source': visitSource,
      'admin_review_status': adminReviewStatus,
      if (adminReviewNote != null) 'admin_review_note': adminReviewNote,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedAt != null) 'reviewed_at': Timestamp.fromDate(reviewedAt!),
      if (createdAt != null) 'created_at': Timestamp.fromDate(createdAt!),
    };
  }

  Visit copyWith({
    String? id,
    String? mrId,
    String? doctorId,
    String? doctorName,
    String? visitDate,
    String? visitTime,
    String? dayOfWeek,
    String? notes,
    int? rating,
    List<String>? feedbackTags,
    double? latitude,
    double? longitude,
    DateTime? locationTimestamp,
    bool? geofenceVerified,
    String? outOfGeofenceReason,
    VisitStatus? status,
    String? visitSource,
    String? adminReviewStatus,
    String? adminReviewNote,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime? createdAt,
  }) {
    return Visit(
      id: id ?? this.id,
      mrId: mrId ?? this.mrId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      visitDate: visitDate ?? this.visitDate,
      visitTime: visitTime ?? this.visitTime,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      feedbackTags: feedbackTags ?? this.feedbackTags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationTimestamp: locationTimestamp ?? this.locationTimestamp,
      geofenceVerified: geofenceVerified ?? this.geofenceVerified,
      outOfGeofenceReason: outOfGeofenceReason ?? this.outOfGeofenceReason,
      status: status ?? this.status,
      visitSource: visitSource ?? this.visitSource,
      adminReviewStatus: adminReviewStatus ?? this.adminReviewStatus,
      adminReviewNote: adminReviewNote ?? this.adminReviewNote,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
