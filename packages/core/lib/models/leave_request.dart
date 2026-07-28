class LeaveRequest {
  final String id;
  final String mrId;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // pending, approved, rejected
  final DateTime requestedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? adminNote;

  LeaveRequest({
    required this.id,
    required this.mrId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.requestedAt,
    this.approvedBy,
    this.approvedAt,
    this.adminNote,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json, String id) {
    return LeaveRequest(
      id: id,
      mrId: json['mr_id'] ?? '',
      leaveType: json['leave_type'] ?? 'Casual',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : DateTime.now(),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : DateTime.now(),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      requestedAt: json['requested_at'] != null ? DateTime.parse(json['requested_at']) : DateTime.now(),
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      adminNote: json['admin_note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mr_id': mrId,
      'leave_type': leaveType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reason': reason,
      'status': status,
      'requested_at': requestedAt.toIso8601String(),
      if (approvedBy != null) 'approved_by': approvedBy,
      if (approvedAt != null) 'approved_at': approvedAt?.toIso8601String(),
      if (adminNote != null) 'admin_note': adminNote,
    };
  }
}
