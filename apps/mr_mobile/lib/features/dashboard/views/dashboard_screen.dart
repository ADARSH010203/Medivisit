import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/dashboard_controller.dart';
import 'quick_log_action_sheet.dart';
import '../../../app/routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Screen
// ─────────────────────────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(DashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshGradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _ctrl.refreshData,
            color: const Color(0xFF4F378A),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Sticky App Bar ────────────────────────────────────────
                SliverToBoxAdapter(child: _DashboardHeader(ctrl: _ctrl)),
                // ── Content ───────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      // Failed Sync Banner
                      _FailedSyncBanner(ctrl: _ctrl),
                      // Smart Pulse Banner
                      _SmartPulseBanner(ctrl: _ctrl),
                      const SizedBox(height: 16),
                      // Stats Row
                      _StatsRow(ctrl: _ctrl),
                      const SizedBox(height: 24),
                      // Module Grid
                      _ModuleGrid(),
                      const SizedBox(height: 24),
                      // Recent Activity
                      _RecentActivitySection(ctrl: _ctrl),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: PillBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == -1) {
            _showQuickLog(context);
          } else {
            switch (index) {
              case 1:
                Get.toNamed(AppRoutes.visits);
                break;
              case 2:
                Get.toNamed(AppRoutes.catalog);
                break;
              case 3:
                Get.toNamed(AppRoutes.performance);
                break;
              case 4:
                Get.toNamed(AppRoutes.profile);
                break;
            }
          }
        },
      ),
    );
  }

  void _showQuickLog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const QuickLogActionSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final DashboardController ctrl;
  const _DashboardHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF).withOpacity(0.85),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
      ),
      child: Obx(() => Row(
            children: [
              // Avatar with gradient ring
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F378A), Color(0xFF008080)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEADDFF),
                    ),
                    child: Center(
                      child: Text(
                        ctrl.firstName.isNotEmpty
                            ? ctrl.firstName[0].toUpperCase()
                            : 'M',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4F378A),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${ctrl.firstName} 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1B20),
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      ctrl.greetingLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF494551),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Sync Status Badge
              _SyncStatusBadge(ctrl: ctrl),
              const SizedBox(width: 8),
              // Notification Bell
              _NotificationBell(ctrl: ctrl),
            ],
          )),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final DashboardController ctrl;
  const _NotificationBell({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = ctrl.unreadNotifications.value;
      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.notifications),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PhosphorIcon(PhosphorIcons.bell(PhosphorIconsStyle.duotone),
                  color: Color(0xFF494551), size: 22),
              if (count > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA1A1A),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFF9F9FF), width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _SyncStatusBadge extends StatelessWidget {
  final DashboardController ctrl;
  const _SyncStatusBadge({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final syncService = ctrl.offlineSyncService;
      final pending = syncService.pendingCount.value;
      final failed = syncService.failedCount.value;
      final isSyncing = syncService.isSyncing.value;

      if (pending == 0 && failed == 0 && !isSyncing) {
        return const SizedBox.shrink();
      }

      final color = failed > 0
          ? const Color(0xFFBA1A1A)
          : const Color(0xFFE8A800);

      return GestureDetector(
        onTap: () {
          if (failed > 0) {
            syncService.retryFailedActions();
            Get.snackbar('Syncing', 'Retrying failed offline items...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white);
          } else {
            syncService.flushOutbox();
          }
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSyncing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8A800)),
                  ),
                )
              else
                PhosphorIcon(
                  failed > 0
                      ? PhosphorIcons.warningCircle(PhosphorIconsStyle.fill)
                      : PhosphorIcons.cloudArrowUp(PhosphorIconsStyle.duotone),
                  color: color,
                  size: 22,
                ),
              if (!isSyncing && (pending > 0 || failed > 0))
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${failed > 0 ? failed : pending}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _FailedSyncBanner extends StatelessWidget {
  final DashboardController ctrl;
  const _FailedSyncBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final failed = ctrl.offlineSyncService.failedCount.value;
      if (failed == 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFBA1A1A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBA1A1A).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
              color: const Color(0xFFBA1A1A),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$failed items failed to sync.',
                style: const TextStyle(
                  color: Color(0xFFBA1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: () => ctrl.offlineSyncService.retryFailedActions(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: const Color(0xFFBA1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Tap to retry', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Smart Pulse Banner
// ─────────────────────────────────────────────────────────────────────────────
class _SmartPulseBanner extends StatelessWidget {
  final DashboardController ctrl;
  const _SmartPulseBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final planned = ctrl.plannedVisitsToday;
      final completed = ctrl.completedVisitsToday;
      final progress = ctrl.visitProgressToday;

      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.visits),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A6BFF), Color(0xFF44DDC1)],
              stops: [0.0, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A6BFF).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Stack(
            children: [
              // Background decorative blob
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Row(
                children: [
                  // Text content
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planned == 0
                              ? 'No visits planned today.'
                              : 'You have $planned doctor visits planned today.',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          planned == 0
                              ? 'Tap to plan your route!'
                              : '$completed already completed!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (ctrl.pendingSelfReportedToday > 0 || ctrl.rejectedSelfReportedToday > 0 || ctrl.approvedSelfReportedToday > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                if (ctrl.approvedSelfReportedToday > 0)
                                  _StatusBadge(icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone), text: '${ctrl.approvedSelfReportedToday} approved', color: AppColors.success),
                                if (ctrl.pendingSelfReportedToday > 0)
                                  _StatusBadge(icon: PhosphorIcons.clock(PhosphorIconsStyle.duotone), text: '${ctrl.pendingSelfReportedToday} pending', color: AppColors.warning),
                                if (ctrl.rejectedSelfReportedToday > 0)
                                  _StatusBadge(icon: PhosphorIcons.xCircle(PhosphorIconsStyle.duotone), text: '${ctrl.rejectedSelfReportedToday} rejected', color: AppColors.error),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Circular Progress
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(64, 64),
                          painter: _CircularProgressPainter(
                              progress: progress),
                        ),
                        Text(
                          planned == 0
                              ? '-'
                              : '$completed/$planned',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  const _CircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 3.5;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _StatusBadge extends StatelessWidget {
  final PhosphorIconData icon;
  final String text;
  final Color color;
  const _StatusBadge({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icon, color: Colors.white, size: 10),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final DashboardController ctrl;
  const _StatsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: PhosphorIcons.calendar(PhosphorIconsStyle.duotone),
                iconColor: const Color(0xFF0055D3),
                label: 'Visits Today',
                value: '${ctrl.completedVisitsToday}/${ctrl.plannedVisitsToday}',
                onTap: () => Get.toNamed(AppRoutes.visits),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                icon: PhosphorIcons.userCheck(PhosphorIconsStyle.duotone),
                iconColor: const Color(0xFF006B5C),
                label: 'Attendance',
                value: ctrl.attendanceMarkedToday.value ? '✓' : 'Mark',
                valueColor: ctrl.attendanceMarkedToday.value
                    ? const Color(0xFF006B5C)
                    : const Color(0xFFE8A800),
                hasGlow: ctrl.attendanceMarkedToday.value,
                onTap: () => Get.toNamed(AppRoutes.markAttendance),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                icon: PhosphorIcons.trendUp(PhosphorIconsStyle.duotone),
                iconColor: const Color(0xFF575C76),
                label: 'This Week',
                value: '${ctrl.weeklyVisitCount.value}',
                onTap: () => Get.toNamed(AppRoutes.visitHistory),
              ),
            ),
          ],
        ));
  }
}

class _StatTile extends StatelessWidget {
  final PhosphorIconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final bool hasGlow;
  final VoidCallback onTap;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.hasGlow = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        level: 2,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            // Gradient value text
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: valueColor != null
                    ? [valueColor!, valueColor!]
                    : [const Color(0xFF0053D3), const Color(0xFF44DDC1)],
              ).createShader(bounds),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424655),
                letterSpacing: 0.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Module Grid (2×2)
// ─────────────────────────────────────────────────────────────────────────────
class _ModuleGrid extends StatelessWidget {
  static final _modules = [
    _ModuleData(
      title: 'Doctor Visits',
      subtitle: 'Log & track',
      icon: PhosphorIcons.stethoscope(PhosphorIconsStyle.duotone),
      iconColor: const Color(0xFF0053D3),
      bgColor: const Color(0x1A1A6BFF),
      route: AppRoutes.visits,
      secondaryRoute: AppRoutes.discoveryMap,
      secondaryLabel: 'Discover',
    ),
    _ModuleData(
      title: 'Products',
      subtitle: 'Catalog & samples',
      icon: PhosphorIcons.pill(PhosphorIconsStyle.duotone),
      iconColor: const Color(0xFF575C76),
      bgColor: const Color(0x1A707490),
      route: AppRoutes.catalog,
    ),
    _ModuleData(
      title: 'Attendance',
      subtitle: 'Mark & history',
      icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.duotone),
      iconColor: const Color(0xFF006B5C),
      bgColor: const Color(0x1A006B5C),
      route: AppRoutes.markAttendance,
    ),
    _ModuleData(
      title: 'Leave',
      subtitle: 'Request & status',
      icon: PhosphorIcons.calendarX(PhosphorIconsStyle.duotone),
      iconColor: const Color(0xFFB45309),
      bgColor: const Color(0x1AF59E0B),
      route: AppRoutes.leaveRequest,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.65,
      ),
      itemCount: _modules.length,
      itemBuilder: (_, i) => _ModuleCard(data: _modules[i]),
    );
  }
}

class _ModuleData {
  final String title;
  final String subtitle;
  final PhosphorIconData icon;
  final Color iconColor;
  final Color bgColor;
  final String route;
  final String? secondaryRoute;
  final String? secondaryLabel;

  const _ModuleData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.route,
    this.secondaryRoute,
    this.secondaryLabel,
  });
}

class _ModuleCard extends StatefulWidget {
  final _ModuleData data;
  const _ModuleCard({required this.data});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _elevation;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _elevation = Tween<double>(begin: 0, end: -4).animate(
        CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => _hoverCtrl.forward(),
      onTapUp: (_) {
        _hoverCtrl.reverse();
        Get.toNamed(widget.data.route);
      },
      onTapCancel: () => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _hoverCtrl,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _elevation.value),
          child: child,
        ),
        child: GlassCard(
          level: 2,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon bubble with animated glow
              AnimatedBuilder(
                animation: _hoverCtrl,
                builder: (context, _) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.data.bgColor,
                    shape: BoxShape.circle,
                    boxShadow: _hoverCtrl.value > 0
                        ? [BoxShadow(
                            color: widget.data.iconColor.withOpacity(0.45 * _hoverCtrl.value),
                            blurRadius: 18,
                            spreadRadius: 2,
                          )]
                        : null,
                  ),
                  child: PhosphorIcon(widget.data.icon,
                      color: widget.data.iconColor, size: 20),
                ),
              ),
              // Text + optional discover chip
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1D1B20),
                    ),
                  ),
                  Text(
                    widget.data.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : const Color(0xFF494551),
                    ),
                  ),
                  if (widget.data.secondaryRoute != null) ...
                  [
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => Get.toNamed(widget.data.secondaryRoute!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PhosphorIcon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill), size: 10, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              widget.data.secondaryLabel ?? 'Discover',
                              style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Activity Section
// ─────────────────────────────────────────────────────────────────────────────
class _RecentActivitySection extends StatelessWidget {
  final DashboardController ctrl;
  const _RecentActivitySection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1D1B20),
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.visitHistory),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF0053D3), Color(0xFF44DDC1)],
                ).createShader(bounds),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (ctrl.recentActivity.isEmpty) {
            return _buildEmptyActivity();
          }
          return Column(
            children: ctrl.recentActivity
                .map((e) {
                  final isOld = DateTime.now().difference(e.timestamp).inMinutes > 60;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Opacity(
                      opacity: isOld ? 0.62 : 1.0,
                      child: _ActivityItem(event: e),
                    ),
                  );
                })
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyActivity() {
    return GlassCard(
      level: 1,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            PhosphorIcon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.duotone),
                size: 40, color: const Color(0xFFCBC4D2)),
            const SizedBox(height: 8),
            const Text(
              'No activity yet today',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A7582),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityEvent event;
  const _ActivityItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final (iconColor, bgColor, icon) = _iconForType(event.type);

    return GlassCard(
      level: 1,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Icon bubble
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1D1B20),
                    ),
                  ),
                  Text(
                    event.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white60
                          : const Color(0xFF494551),
                    ),
                  ),
              ],
            ),
          ),
          // Timestamp
          Text(
            timeago.format(event.timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7A7582),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, PhosphorIconData) _iconForType(ActivityEventType type) {
    switch (type) {
      case ActivityEventType.visit:
        return (
          const Color(0xFF006B5C),
          const Color(0x1A006B5C),
          PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone)
        );
      case ActivityEventType.attendance:
        return (
          const Color(0xFF0053D3),
          const Color(0x1A1A6BFF),
          PhosphorIcons.userCheck(PhosphorIconsStyle.duotone)
        );
      case ActivityEventType.leave:
        return (
          const Color(0xFFB45309),
          const Color(0x1AF59E0B),
          PhosphorIcons.calendarX(PhosphorIconsStyle.duotone)
        );
      case ActivityEventType.expense:
        return (
          const Color(0xFF7C3AED),
          const Color(0x1A7C3AED),
          PhosphorIcons.receipt(PhosphorIconsStyle.duotone)
        );
      case ActivityEventType.checkIn:
        return (
          const Color(0xFF0053D3),
          const Color(0x1A0053D3),
          PhosphorIcons.mapPinPlus(PhosphorIconsStyle.duotone)
        );
    }
  }
}
