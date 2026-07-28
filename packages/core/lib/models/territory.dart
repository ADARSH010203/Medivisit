import 'package:cloud_firestore/cloud_firestore.dart';

class Territory {
  final String id;
  final String name;
  final String region;
  final GeoPoint? officeLocation;
  final int geofenceRadiusM;
  final List<String> assignedMrIds;
  final DateTime? createdAt;

  Territory({
    required this.id,
    required this.name,
    required this.region,
    this.officeLocation,
    required this.geofenceRadiusM,
    required this.assignedMrIds,
    this.createdAt,
  });

  factory Territory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Territory(
      id: doc.id,
      name: data['name'] ?? '',
      region: data['region'] ?? '',
      officeLocation: data['office_location'],
      geofenceRadiusM: data['geofence_radius_m'] ?? 150,
      assignedMrIds: List<String>.from(data['assigned_mr_ids'] ?? []),
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'region': region,
      if (officeLocation != null) 'office_location': officeLocation,
      'geofence_radius_m': geofenceRadiusM,
      'assigned_mr_ids': assignedMrIds,
      if (createdAt != null) 'created_at': Timestamp.fromDate(createdAt!),
    };
  }
}
