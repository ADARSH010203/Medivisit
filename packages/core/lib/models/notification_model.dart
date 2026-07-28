class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String imageUrl;
  final String type;
  final String sentTo;
  final bool sentByAdmin;
  final DateTime sentAt;
  final DateTime? scheduledAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.type,
    required this.sentTo,
    required this.sentByAdmin,
    required this.sentAt,
    this.scheduledAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, String id) {
    return NotificationModel(
      id: id,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['image_url'] ?? '',
      type: json['type'] ?? 'general',
      sentTo: json['sent_to'] ?? '',
      sentByAdmin: json['sent_by_admin'] ?? false,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : DateTime.now(),
      scheduledAt: json['scheduled_at'] != null ? DateTime.parse(json['scheduled_at']) : null,
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'type': type,
      'sent_to': sentTo,
      'sent_by_admin': sentByAdmin,
      'sent_at': sentAt.toIso8601String(),
      if (scheduledAt != null) 'scheduled_at': scheduledAt?.toIso8601String(),
      'is_read': isRead,
    };
  }
}
