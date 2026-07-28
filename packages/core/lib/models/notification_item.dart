import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String type;
  final String sentTo;
  final bool sentByAdmin;
  final DateTime? sentAt;
  final DateTime? scheduledAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.type,
    required this.sentTo,
    required this.sentByAdmin,
    this.sentAt,
    this.scheduledAt,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['image_url'],
      type: data['type'] ?? '',
      sentTo: data['sent_to'] ?? '',
      sentByAdmin: data['sent_by_admin'] ?? false,
      sentAt: data['sent_at'] != null ? (data['sent_at'] as Timestamp).toDate() : null,
      scheduledAt: data['scheduled_at'] != null ? (data['scheduled_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      if (imageUrl != null) 'image_url': imageUrl,
      'type': type,
      'sent_to': sentTo,
      'sent_by_admin': sentByAdmin,
      if (sentAt != null) 'sent_at': Timestamp.fromDate(sentAt!),
      if (scheduledAt != null) 'scheduled_at': Timestamp.fromDate(scheduledAt!),
    };
  }
}
