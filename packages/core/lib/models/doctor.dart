import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String qualification;
  final String clinicName;
  final String clinicAddress;
  final GeoPoint clinicLocation;
  final int geofenceRadiusM;
  final String phone;
  final String bio;
  final String? photoUrl;
  final List<String> availableDays;
  final String timingStart;
  final String timingEnd;
  final bool isActive;
  final bool isHighPriority;
  final int totalVisits;
  final String source; // 'admin_created' | 'mr_reported'
  final String? reportedByMr;
  final double engagementRating;
  final int totalVisitsByMrs;
  final double sampleAcceptanceRate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.clinicName,
    required this.clinicAddress,
    required this.clinicLocation,
    required this.geofenceRadiusM,
    required this.phone,
    required this.bio,
    this.photoUrl,
    required this.availableDays,
    required this.timingStart,
    required this.timingEnd,
    required this.isActive,
    required this.isHighPriority,
    required this.totalVisits,
    this.source = 'admin_created',
    this.reportedByMr,
    this.engagementRating = 0.0,
    this.totalVisitsByMrs = 0,
    this.sampleAcceptanceRate = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Doctor(
      id: doc.id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      qualification: data['qualification'] ?? '',
      clinicName: data['clinic_name'] ?? '',
      clinicAddress: data['clinic_address'] ?? '',
      clinicLocation: data['clinic_location'] ?? const GeoPoint(0, 0),
      geofenceRadiusM: data['geofence_radius_m'] ?? 150,
      phone: data['phone'] ?? '',
      bio: data['bio'] ?? '',
      photoUrl: data['photo_url'],
      availableDays: List<String>.from(data['available_days'] ?? []),
      timingStart: data['timing_start'] ?? '09:00',
      timingEnd: data['timing_end'] ?? '17:00',
      isActive: data['is_active'] ?? true,
      isHighPriority: data['is_high_priority'] ?? false,
      totalVisits: data['total_visits'] ?? 0,
      source: data['source'] ?? 'admin_created',
      reportedByMr: data['reported_by_mr'],
      engagementRating: (data['engagement_rating'] as num?)?.toDouble() ?? 0.0,
      totalVisitsByMrs: data['total_visits_by_mrs'] ?? 0,
      sampleAcceptanceRate: (data['sample_acceptance_rate'] as num?)?.toDouble() ?? 0.0,
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
      updatedAt: data['updated_at'] != null ? (data['updated_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialty': specialty,
      'qualification': qualification,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'clinic_location': clinicLocation,
      'geofence_radius_m': geofenceRadiusM,
      'phone': phone,
      'bio': bio,
      if (photoUrl != null) 'photo_url': photoUrl,
      'available_days': availableDays,
      'timing_start': timingStart,
      'timing_end': timingEnd,
      'is_active': isActive,
      'is_high_priority': isHighPriority,
      'total_visits': totalVisits,
      'source': source,
      'engagement_rating': engagementRating,
      'total_visits_by_mrs': totalVisitsByMrs,
      'sample_acceptance_rate': sampleAcceptanceRate,
      if (reportedByMr != null) 'reported_by_mr': reportedByMr,
      if (createdAt != null) 'created_at': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? specialty,
    String? qualification,
    String? clinicName,
    String? clinicAddress,
    GeoPoint? clinicLocation,
    int? geofenceRadiusM,
    String? phone,
    String? bio,
    String? photoUrl,
    List<String>? availableDays,
    String? timingStart,
    String? timingEnd,
    bool? isActive,
    bool? isHighPriority,
    int? totalVisits,
    String? source,
    String? reportedByMr,
    double? engagementRating,
    int? totalVisitsByMrs,
    double? sampleAcceptanceRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      qualification: qualification ?? this.qualification,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicLocation: clinicLocation ?? this.clinicLocation,
      geofenceRadiusM: geofenceRadiusM ?? this.geofenceRadiusM,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      availableDays: availableDays ?? this.availableDays,
      timingStart: timingStart ?? this.timingStart,
      timingEnd: timingEnd ?? this.timingEnd,
      isActive: isActive ?? this.isActive,
      isHighPriority: isHighPriority ?? this.isHighPriority,
      totalVisits: totalVisits ?? this.totalVisits,
      source: source ?? this.source,
      reportedByMr: reportedByMr ?? this.reportedByMr,
      engagementRating: engagementRating ?? this.engagementRating,
      totalVisitsByMrs: totalVisitsByMrs ?? this.totalVisitsByMrs,
      sampleAcceptanceRate: sampleAcceptanceRate ?? this.sampleAcceptanceRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
