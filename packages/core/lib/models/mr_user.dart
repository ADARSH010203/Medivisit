import 'package:cloud_firestore/cloud_firestore.dart';

class MrUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isVerified;
  final bool isBlocked;
  final String? territoryId;
  final String? profilePhotoUrl;
  final String language;
  final bool darkMode;
  final DateTime? lastActive;
  final int attendanceStreak;
  final int totalVisits;
  final double avgRating;
  final double performancePercent;
  final List<String> fcmTokens;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MrUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerified,
    required this.isBlocked,
    this.territoryId,
    this.profilePhotoUrl,
    required this.language,
    required this.darkMode,
    this.lastActive,
    this.attendanceStreak = 0,
    this.totalVisits = 0,
    this.avgRating = 0.0,
    this.performancePercent = 0.0,
    required this.fcmTokens,
    this.createdAt,
    this.updatedAt,
  });

  factory MrUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MrUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'mr',
      isVerified: data['is_verified'] ?? false,
      isBlocked: data['is_blocked'] ?? false,
      territoryId: data['territory_id'],
      profilePhotoUrl: data['profile_photo_url'],
      language: data['language'] ?? 'en',
      darkMode: data['dark_mode'] ?? false,
      lastActive: data['last_active'] != null ? (data['last_active'] as Timestamp).toDate() : null,
      attendanceStreak: data['attendance_streak'] ?? 0,
      totalVisits: data['total_visits'] ?? 0,
      avgRating: (data['avg_rating'] ?? 0.0).toDouble(),
      performancePercent: (data['performance_percent'] ?? 0.0).toDouble(),
      fcmTokens: List<String>.from(data['fcm_tokens'] ?? []),
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
      updatedAt: data['updated_at'] != null ? (data['updated_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_verified': isVerified,
      'is_blocked': isBlocked,
      if (territoryId != null) 'territory_id': territoryId,
      if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
      'language': language,
      'dark_mode': darkMode,
      if (lastActive != null) 'last_active': Timestamp.fromDate(lastActive!),
      'attendance_streak': attendanceStreak,
      'total_visits': totalVisits,
      'avg_rating': avgRating,
      'performance_percent': performancePercent,
      'fcm_tokens': fcmTokens,
      if (createdAt != null) 'created_at': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }

  MrUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isVerified,
    bool? isBlocked,
    String? territoryId,
    String? profilePhotoUrl,
    String? language,
    bool? darkMode,
    DateTime? lastActive,
    int? attendanceStreak,
    int? totalVisits,
    double? avgRating,
    double? performancePercent,
    List<String>? fcmTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MrUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isBlocked: isBlocked ?? this.isBlocked,
      territoryId: territoryId ?? this.territoryId,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      lastActive: lastActive ?? this.lastActive,
      attendanceStreak: attendanceStreak ?? this.attendanceStreak,
      totalVisits: totalVisits ?? this.totalVisits,
      avgRating: avgRating ?? this.avgRating,
      performancePercent: performancePercent ?? this.performancePercent,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
