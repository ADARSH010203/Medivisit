import 'package:get/get.dart';
import 'package:core/core.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _notificationRepo = Get.find<NotificationRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    isLoading.value = true;
    try {
      final user = await _authService.getFreshUserRecord();
      if (user == null) return;
      
      notifications.value = await _notificationRepo.getNotifications(user.uid);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepo.markAsRead(notificationId);
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notif = notifications[index];
        notifications[index] = NotificationModel(
          id: notif.id,
          title: notif.title,
          body: notif.body,
          imageUrl: notif.imageUrl,
          type: notif.type,
          sentTo: notif.sentTo,
          sentByAdmin: notif.sentByAdmin,
          sentAt: notif.sentAt,
          scheduledAt: notif.scheduledAt,
          isRead: true,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark as read');
    }
  }
}
