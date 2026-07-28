import 'package:cloud_firestore/cloud_firestore.dart';
import '../notification_repository.dart';
import '../../models/notification_model.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<NotificationModel>> getNotifications(String mrId) async {
    final snapshot = await _firestore.collection('notifications')
        .where('sent_to', whereIn: ['all_mrs', mrId]) // Also would need territory logic in a real app
        .orderBy('sent_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => NotificationModel.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({'is_read': true});
  }

  @override
  Future<void> markAllAsRead(String mrId) async {
    // Note: This is an approximation. We'd ideally query unread ones directed at this MR.
    final snapshot = await _firestore.collection('notifications')
        .where('sent_to', whereIn: ['all_mrs', mrId])
        .where('is_read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  @override
  Stream<int> streamUnreadCount(String mrId) {
    return _firestore.collection('notifications')
        .where('sent_to', whereIn: ['all_mrs', mrId])
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
