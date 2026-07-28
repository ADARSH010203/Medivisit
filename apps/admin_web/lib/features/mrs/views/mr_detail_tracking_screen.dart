import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/mr_detail_tracking_controller.dart';

class MrDetailTrackingScreen extends GetView<MrDetailTrackingController> {
  const MrDetailTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MrDetailTrackingController());

    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: const Text('MR Tracking Details',
            style: TextStyle(color: Colors.white, fontFamily: 'Geist', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.adminAccentStart));
        }

        final mr = controller.mrUser.value;
        if (mr == null) return const Center(child: Text('MR not found', style: TextStyle(color: Colors.white)));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Profile Card ──
              _buildHeaderCard(mr),

              const SizedBox(height: 28),

              // ── Glass Pill Tabs ──
              Row(
                children: [
                  _TabPill(title: 'Overview', index: 0, ctrl: controller),
                  const SizedBox(width: 12),
                  _TabPill(title: 'Performance', index: 1, ctrl: controller),
                  const SizedBox(width: 12),
                  _TabPill(title: 'Visits', index: 2, ctrl: controller),
                  const SizedBox(width: 12),
                  _TabPill(title: 'Territory Map', index: 3, ctrl: controller),
                ],
              ),

              const SizedBox(height: 24),

              // ── Tab Views ──
              Obx(() {
                switch (controller.selectedTabIndex.value) {
                  case 0:
                    return _buildOverviewTab(mr);
                  case 1:
                    return _buildPerformanceTab();
                  case 2:
                    return _buildVisitsTab(context);
                  case 3:
                    return _buildTerritoryMapTab();
                  default:
                    return _buildOverviewTab(mr);
                }
              }),
            ],
          ),
        );
      }),
    );
  }

  // ── HEADER PROFILE CARD (matches HTML: glass-panel with inner cyan glow) ──
  Widget _buildHeaderCard(MrUser mr) {
    return AdminGlassCard(
      child: Stack(
        children: [
          // Inner cyan glow orb (top-left)
          Positioned(
            top: -24,
            left: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F2FF).withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00DBE7).withOpacity(0.1),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Avatar with glow ring
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0053D3), Color(0xFF44DDC1)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mr.name[0],
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            mr.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Geist',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: controller.isBlocked.value
                                  ? const Color(0xFFBA1A1A).withOpacity(0.2)
                                  : const Color(0xFF00F2FF).withOpacity(0.15),
                              border: Border.all(
                                color: controller.isBlocked.value
                                    ? const Color(0xFFBA1A1A).withOpacity(0.4)
                                    : const Color(0xFF74F5FF).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              controller.isBlocked.value ? 'Blocked' : 'Active',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: controller.isBlocked.value
                                    ? const Color(0xFFFFB4AB)
                                    : const Color(0xFF74F5FF),
                              ),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Senior Medical Representative • ${mr.territoryId ?? 'Unassigned'}',
                        style: const TextStyle(color: Color(0xFFB9CACB), fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          PhosphorIcon(PhosphorIcons.envelope(PhosphorIconsStyle.regular), size: 14, color: const Color(0xFF849495)),
                          const SizedBox(width: 4),
                          Text(mr.email, style: const TextStyle(color: Color(0xFF849495), fontSize: 12)),
                          const SizedBox(width: 16),
                          PhosphorIcon(PhosphorIcons.phone(PhosphorIconsStyle.regular), size: 14, color: const Color(0xFF849495)),
                          const SizedBox(width: 4),
                          Text(mr.phone, style: const TextStyle(color: Color(0xFF849495), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: controller.isBlocked.value
                              ? const Color(0xFF006B5C)
                              : const Color(0xFFFFB4AB).withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: controller.toggleBlockAccount,
                      child: Text(
                        controller.isBlocked.value ? 'Unblock Account' : 'Block Account',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: controller.isBlocked.value
                              ? const Color(0xFF006B5C)
                              : const Color(0xFFFFB4AB),
                        ),
                      ),
                    )),
                    const SizedBox(height: 8),
                    const Text(
                      'Last active: 12 mins ago',
                      style: TextStyle(color: Color(0xFFB9CACB), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── OVERVIEW TAB (KPI cards with corner glows + progress bars) ──
  Widget _buildOverviewTab(MrUser mr) {
    return Column(
      children: [
        // KPI Row
        Row(
          children: [
            Expanded(child: _buildKpiCard(
              'COMPLETED VISITS',
              '${controller.recentVisits.length}',
              '/ 150',
              PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone),
              const Color(0xFF00F2FF),
              progressValue: controller.recentVisits.length / 150.0,
            )),
            const SizedBox(width: 20),
            Expanded(child: _buildKpiCard(
              'AVG CLINIC TIME',
              '42',
              'mins',
              PhosphorIcons.timer(PhosphorIconsStyle.duotone),
              const Color(0xFFD1BCFF),
              trendText: '+5% vs avg',
            )),
            const SizedBox(width: 20),
            Expanded(child: _buildKpiCard(
              'TERRITORY COVERAGE',
              '${controller.attendanceRate.value}%',
              null,
              PhosphorIcons.target(PhosphorIconsStyle.duotone),
              const Color(0xFFFFB1C3),
            )),
          ],
        ),

        const SizedBox(height: 24),

        // Territory Map (compact in overview)
        SizedBox(
          height: 400,
          child: _buildMapCard(),
        ),

        const SizedBox(height: 24),

        // Recent Visits Table
        _buildRecentVisitsTable(),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, String? suffix, PhosphorIconData icon, Color accentColor, {double? progressValue, String? trendText}) {
    return AdminGlassCard(
      child: Stack(
        children: [
          // Corner Glow
          Positioned(
            top: -12,
            right: -12,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                        color: Color(0xFFB9CACB),
                        fontFamily: 'Geist',
                      ),
                    ),
                    PhosphorIcon(icon, size: 20, color: const Color(0xFF849495)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [accentColor, Colors.white],
                      ).createShader(bounds),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                    if (suffix != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        suffix,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB9CACB),
                          fontFamily: 'Geist',
                        ),
                      ),
                    ],
                  ],
                ),
                if (progressValue != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressValue.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [const Color(0xFF74F5FF), accentColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                if (trendText != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      PhosphorIcon(PhosphorIcons.trendUp(PhosphorIconsStyle.bold), size: 14, color: const Color(0xFF74F5FF)),
                      const SizedBox(width: 4),
                      Text(
                        trendText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF74F5FF),
                          fontFamily: 'Geist',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── MAP CARD (with overlaid title + action buttons) ──
  Widget _buildMapCard() {
    return AdminGlassCard(
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          // Map
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: controller.officeLocation,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.medivisit.pro',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: controller.officeLocation,
                      color: const Color(0xFF0053D3).withOpacity(0.15),
                      borderColor: const Color(0xFF0053D3),
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                      radius: 150,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: controller.officeLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.business, color: Color(0xFF0053D3), size: 36),
                    ),
                    ...controller.recentVisits.map((visit) {
                      Color pinColor = const Color(0xFFE8A800);
                      if (visit.adminReviewStatus == 'approved' || visit.status == VisitStatus.visited) {
                        pinColor = const Color(0xFF006B5C);
                      } else if (visit.adminReviewStatus == 'rejected') {
                        pinColor = const Color(0xFFBA1A1A);
                      }

                      return Marker(
                        point: LatLng(visit.latitude ?? 19.0760, visit.longitude ?? 72.8777),
                        width: 36,
                        height: 36,
                        child: Container(
                          decoration: BoxDecoration(
                            color: pinColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Overlaid Title
          Positioned(
            top: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Territory Heat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
                const Text(
                  'Focus Region Overview',
                  style: TextStyle(
                    color: Color(0xFF74F5FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Geist',
                    letterSpacing: 0.5,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
              ],
            ),
          ),

          // Overlaid Action Buttons
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                _mapActionButton(PhosphorIcons.funnel(PhosphorIconsStyle.bold)),
                const SizedBox(width: 6),
                _mapActionButton(PhosphorIcons.arrowsOut(PhosphorIconsStyle.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapActionButton(PhosphorIconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFF101221).withOpacity(0.8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Center(
        child: PhosphorIcon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  // ── RECENT VISITS TABLE (HTML-accurate with icon badges & glowing status dots) ──
  Widget _buildRecentVisitsTable() {
    return AdminGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Table Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              color: Colors.white.withOpacity(0.02),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Visits',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      const Text(
                        'VIEW ALL',
                        style: TextStyle(
                          color: Color(0xFF74F5FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                          fontFamily: 'Geist',
                        ),
                      ),
                      const SizedBox(width: 4),
                      PhosphorIcon(PhosphorIcons.arrowRight(PhosphorIconsStyle.bold), size: 14, color: const Color(0xFF74F5FF)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Table Column Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              color: Colors.white.withOpacity(0.01),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('CLINIC / ENTITY', style: _tableHeaderStyle)),
                Expanded(flex: 2, child: Text('DATE & TIME', style: _tableHeaderStyle)),
                Expanded(flex: 2, child: Text('OBJECTIVE', style: _tableHeaderStyle)),
                Expanded(flex: 2, child: Text('STATUS', style: _tableHeaderStyle)),
                SizedBox(width: 40),
              ],
            ),
          ),

          // Table Rows
          if (controller.recentVisits.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No visits recorded', style: TextStyle(color: Colors.white54)),
            )
          else
            ...controller.recentVisits.take(5).map((visit) {
              StatusPillType pillType = StatusPillType.warning;
              String statusLabel = 'Pending';
              Color statusColor = const Color(0xFFE8A800);

              if (visit.adminReviewStatus == 'approved' || visit.status == VisitStatus.visited) {
                pillType = StatusPillType.success;
                statusLabel = 'Completed';
                statusColor = const Color(0xFF74F5FF);
              } else if (visit.adminReviewStatus == 'rejected') {
                pillType = StatusPillType.error;
                statusLabel = 'Canceled';
                statusColor = const Color(0xFF849495);
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                ),
                child: Row(
                  children: [
                    // Clinic with icon badge
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: const Color(0xFF1D1F2D),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00DBE7).withOpacity(0.08),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: PhosphorIcon(
                                PhosphorIcons.hospital(PhosphorIconsStyle.duotone),
                                size: 16,
                                color: const Color(0xFF74F5FF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              visit.doctorName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Date & Time
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${visit.visitDate} ${visit.visitTime}',
                        style: const TextStyle(color: Color(0xFFB9CACB), fontSize: 13),
                      ),
                    ),

                    // Objective
                    Expanded(
                      flex: 2,
                      child: Text(
                        visit.notes ?? 'Product Presentation',
                        style: const TextStyle(color: Color(0xFFB9CACB), fontSize: 13),
                      ),
                    ),

                    // Status Pill with glowing dot
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: statusColor.withOpacity(0.1),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: statusColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: statusColor.withOpacity(0.8),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Geist',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        icon: PhosphorIcon(PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold), size: 18, color: const Color(0xFF849495)),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return AdminGlassCard(
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Visit Trend Performance',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Geist')),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: controller.visitTrendSpots.toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsTab(BuildContext context) {
    if (controller.recentVisits.isEmpty) {
      return const Center(child: Text('No visits recorded', style: TextStyle(color: Colors.white54)));
    }

    return AdminGlassCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentVisits.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 24),
        itemBuilder: (context, index) {
          final visit = controller.recentVisits[index];
          StatusPillType pillType = StatusPillType.warning;
          if (visit.adminReviewStatus == 'approved' || visit.status == VisitStatus.visited) {
            pillType = StatusPillType.success;
          } else if (visit.adminReviewStatus == 'rejected') {
            pillType = StatusPillType.error;
          }

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: PhosphorIcon(PhosphorIcons.stethoscope(PhosphorIconsStyle.duotone), color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit.doctorName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${visit.visitDate} ${visit.visitTime}',
                        style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              StatusPill(text: visit.status.name.toUpperCase(), type: pillType),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.comment, size: 14, color: AppColors.adminAccentStart),
                label: const Text('Feedback', style: TextStyle(color: AppColors.adminAccentStart, fontSize: 12)),
                onPressed: () => _showFeedbackModal(context, visitId: visit.id),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTerritoryMapTab() {
    return SizedBox(
      height: 450,
      child: _buildMapCard(),
    );
  }

  void _showFeedbackModal(BuildContext context, {String? visitId}) {
    final tags = ['Needs Improvement', 'Excellent Pitch', 'Follow-up Required', 'Sample Accepted'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A313D),
        title: const Text('Manager Feedback Form', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Coaching Tags:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      final selected = controller.selectedTags.contains(tag);
                      return FilterChip(
                        selected: selected,
                        label: Text(tag, style: TextStyle(color: selected ? Colors.black : Colors.white, fontSize: 12)),
                        selectedColor: AppColors.adminAccentStart,
                        backgroundColor: Colors.black26,
                        onSelected: (_) => controller.toggleTag(tag),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: controller.feedbackNoteController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter manager feedback notes...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: AppColors.adminBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminAccentStart),
            onPressed: () => controller.submitFeedback(visitId: visitId),
            child: const Text('Submit Feedback', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static const _tableHeaderStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    color: Color(0xFFB9CACB),
    fontFamily: 'Geist',
  );
}

class _TabPill extends StatelessWidget {
  final String title;
  final int index;
  final MrDetailTrackingController ctrl;

  const _TabPill({required this.title, required this.index, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = ctrl.selectedTabIndex.value == index;
      return GestureDetector(
        onTap: () => ctrl.selectedTabIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: isSelected
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFF323443).withOpacity(0.3),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00F2FF)
                  : Colors.white.withOpacity(0.05),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00F2FF).withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              fontFamily: 'Geist',
              color: isSelected ? const Color(0xFF74F5FF) : const Color(0xFFB9CACB),
            ),
          ),
        ),
      );
    });
  }
}
