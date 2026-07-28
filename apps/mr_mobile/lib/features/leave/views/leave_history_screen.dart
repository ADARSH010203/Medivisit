import 'dart:ui';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/leave_history_controller.dart';
import 'leave_request_screen.dart';

class LeaveHistoryScreen extends GetView<LeaveHistoryController> {
  const LeaveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Leave History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFF0053D3).withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
              onPressed: () => Get.to(() => const LeaveRequestScreen()),
              icon: PhosphorIcon(PhosphorIcons.plus(PhosphorIconsStyle.bold), size: 16, color: const Color(0xFF0053D3)),
              label: const Text(
                'New Request',
                style: TextStyle(color: Color(0xFF0053D3), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: MeshGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header description
                Text(
                  'Review and manage your time off balances and requests.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : const Color(0xFF424655),
                  ),
                ),
                const SizedBox(height: 20),

                // Top Summary Stat Cards Grid (Available, Used, Pending)
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Available', '12', 'days', PhosphorIcons.calendarCheck(PhosphorIconsStyle.duotone), const Color(0xFF0053D3), isDark)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Used', '6', 'days', PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.duotone), const Color(0xFF707490), isDark)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Pending', '1', 'request', PhosphorIcons.hourglass(PhosphorIconsStyle.duotone), const Color(0xFFE8A800), isDark)),
                  ],
                ),

                const SizedBox(height: 28),

                // Recent Requests Section Header
                Text(
                  'RECENT REQUESTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF424655),
                  ),
                ),
                const SizedBox(height: 12),

                // Leave Requests List
                Obx(() {
                  if (controller.isLoading.value && controller.leaveRequests.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.leaveRequests.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.leaveRequests.length,
                    itemBuilder: (context, index) {
                      final req = controller.leaveRequests[index];
                      return _buildLeaveCard(req, isDark);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit, PhosphorIconData icon, Color accentColor, bool isDark) {
    return Stack(
      children: [
        GlassCard(
          level: 2,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PhosphorIcon(icon, size: 16, color: accentColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF424655),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF151C27),
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Corner Glow Blob
        Positioned(
          top: -15,
          right: -15,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.18),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.25),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveCard(LeaveRequest req, bool isDark) {
    final format = DateFormat('MMM d, y');
    Color statusColor;
    String statusText;

    switch (req.status.toLowerCase()) {
      case 'approved':
        statusColor = const Color(0xFF006B5C);
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = const Color(0xFFBA1A1A);
        statusText = 'Rejected';
        break;
      default:
        statusColor = const Color(0xFFE8A800);
        statusText = 'Pending';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        level: 2,
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Accent Left Border
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE7EEFE),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Text(
                              req.leaveType,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF151C27),
                              ),
                            ),
                          ),
                          // Status Pill with Pulsating Dot
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: statusColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: statusColor.withOpacity(0.6),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${format.format(req.startDate)} - ${format.format(req.endDate)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF151C27),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        req.reason,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : const Color(0xFF424655),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          PhosphorIcon(
            PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
            size: 56,
            color: const Color(0xFF0053D3),
          ),
          const SizedBox(height: 12),
          Text(
            'No leave requests yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF151C27),
            ),
          ),
        ],
      ),
    );
  }
}
