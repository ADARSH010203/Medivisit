import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(String mrId);
  
  Future<void> markAsRead(String id);
  
  Future<void> markAllAsRead(String mrId);
  
  Stream<int> streamUnreadCount(String mrId);
}
