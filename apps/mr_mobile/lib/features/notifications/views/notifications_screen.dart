import 'dart:ui';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/notifications_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(() {
            final unreadCount = controller.notifications.where((n) => !n.isRead).length;
            if (unreadCount == 0) return const SizedBox.shrink();

            return TextButton(
              onPressed: () {
                for (var n in controller.notifications.where((n) => !n.isRead)) {
                  controller.markAsRead(n.id);
                }
              },
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF0053D3), Color(0xFF1A6BFF)],
                ).createShader(bounds),
                child: const Text(
                  'MARK ALL AS READ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: MeshGradientBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.notifications.isEmpty) {
              return _buildEmptyState(isDark);
            }

            final unreadCount = controller.notifications.where((n) => !n.isRead).length;
            final now = DateTime.now();
            final todayNotifs = controller.notifications.where((n) => n.sentAt.day == now.day && n.sentAt.month == now.month).toList();
            final earlierNotifs = controller.notifications.where((n) => !(n.sentAt.day == now.day && n.sentAt.month == now.month)).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  Text(
                    unreadCount > 0 ? 'You have $unreadCount unread ${unreadCount == 1 ? 'message' : 'messages'}.' : 'You are all caught up!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : const Color(0xFF424655),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Today Section
                  if (todayNotifs.isNotEmpty) ...[
                    Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...todayNotifs.map((notif) => _buildNotificationCard(notif, context, isDark)),
                    const SizedBox(height: 20),
                  ],

                  // Earlier Section
                  if (earlierNotifs.isNotEmpty) ...[
                    Text(
                      'EARLIER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...earlierNotifs.map((notif) => _buildNotificationCard(notif, context, isDark)),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notif, BuildContext context, bool isDark) {
    final isUnread = !notif.isRead;

    // Color gradient & Icon based on notification category/type
    List<Color> gradientColors;
    PhosphorIconData iconData;

    switch (notif.type.toLowerCase()) {
      case 'urgent':
      case 'alert':
        gradientColors = [const Color(0xFFFFDAD6), const Color(0xFFBA1A1A)];
        iconData = PhosphorIcons.warning(PhosphorIconsStyle.duotone);
        break;
      case 'leave_update':
      case 'approval':
        gradientColors = [const Color(0xFF68FADD), const Color(0xFF006B5C)];
        iconData = PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone);
        break;
      case 'reminder':
        gradientColors = [const Color(0xFF707490), const Color(0xFF575C76)];
        iconData = PhosphorIcons.clock(PhosphorIconsStyle.duotone);
        break;
      default:
        gradientColors = [const Color(0xFF0053D3), const Color(0xFF1A6BFF)];
        iconData = PhosphorIcons.fileText(PhosphorIconsStyle.duotone);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          if (isUnread) controller.markAsRead(notif.id);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: isUnread
                    ? const Color(0xFF1A6BFF).withOpacity(isDark ? 0.15 : 0.08)
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnread
                      ? const Color(0xFF1A6BFF).withOpacity(0.3)
                      : Colors.white.withOpacity(0.4),
                ),
                boxShadow: isUnread
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1A6BFF).withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Unread Accent Bar
                    if (isUnread)
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A6BFF),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A6BFF).withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon Bubble with Gradient
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: gradientColors.last.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: PhosphorIcon(
                                  iconData,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif.title,
                                          style: TextStyle(
                                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                            fontSize: 14,
                                            color: isDark ? Colors.white : const Color(0xFF151C27),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        timeago.format(notif.sentAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isUnread ? const Color(0xFF0053D3) : (isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687)),
                                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif.body,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white70 : const Color(0xFF424655),
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            PhosphorIcons.bellSlash(PhosphorIconsStyle.duotone),
            size: 64,
            color: const Color(0xFF0053D3),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF151C27),
            ),
          ),
        ],
      ),
    );
  }
}
