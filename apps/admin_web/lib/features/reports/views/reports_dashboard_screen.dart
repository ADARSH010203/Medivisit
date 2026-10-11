import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/reports_controller.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page Header Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports & Analytics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Geist',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Clinical performance overview',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB9CACB),
                      fontFamily: 'Geist',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Date Range Glass Picker
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white.withOpacity(0.12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
                          size: 15,
                          color: const Color(0xFF74F5FF),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Q3 2023: Jul 1 - Sep 30',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Geist'),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFFB9CACB), size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    icon: PhosphorIcon(PhosphorIcons.fileCsv(PhosphorIconsStyle.duotone),
                        color: const Color(0xFF74F5FF), size: 16),
                    label: const Text('Export CSV',
                        style: TextStyle(
                            color: Color(0xFF74F5FF), fontWeight: FontWeight.bold, fontFamily: 'Geist')),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0xFF74F5FF).withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: controller.exportCsv,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: PhosphorIcon(PhosphorIcons.filePdf(PhosphorIconsStyle.duotone),
                        color: const Color(0xFF00363A), size: 16),
                    label: const Text('Export PDF',
                        style: TextStyle(
                            color: Color(0xFF00363A), fontWeight: FontWeight.bold, fontFamily: 'Geist')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF74F5FF),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: controller.exportPdf,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(80),
                  child: CircularProgressIndicator(color: Color(0xFF74F5FF)),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── KPI Row ──
                Row(
                  children: [
                    Expanded(
                        child: _buildKpiCard(
                      'TOTAL VISITS',
                      controller.totalVisitsThisMonth.value.toString(),
                      '+12%',
                      true,
                      PhosphorIcons.mapPin(PhosphorIconsStyle.duotone),
                      const Color(0xFF74F5FF),
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildKpiCard(
                      'AVG VISITS / MR',
                      controller.avgVisitsPerMR.value.toStringAsFixed(1),
                      '+5%',
                      true,
                      PhosphorIcons.chartLineUp(PhosphorIconsStyle.duotone),
                      const Color(0xFFD1BCFF),
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildKpiCard(
                      'TOTAL EXPENSES',
                      '₹${controller.totalExpensesThisMonth.value.toStringAsFixed(0)}',
                      '-2%',
                      false,
                      PhosphorIcons.receipt(PhosphorIconsStyle.duotone),
                      const Color(0xFFFFB1C3),
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildKpiCard(
                      'ATTENDANCE RATE',
                      '${controller.attendanceRate.value}%',
                      '+1.5%',
                      true,
                      PhosphorIcons.fingerprint(PhosphorIconsStyle.duotone),
                      const Color(0xFF74F5FF),
                    )),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Bento 3-Col Grid for Charts ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visits by Territory / Visit Trend (2/3 width)
                    Expanded(
                      flex: 2,
                      child: _buildChartCard(
                        title: 'Visit Trend (Last 6 Months)',
                        subtitle: 'Geospatial concentration',
                        accentColor: const Color(0xFF74F5FF),
                        child: SizedBox(
                          height: 280,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                horizontalInterval: 5,
                                getDrawingHorizontalLine: (val) => FlLine(
                                  color: Colors.white.withOpacity(0.05),
                                  strokeWidth: 1,
                                ),
                                drawVerticalLine: false,
                              ),
                              titlesData: FlTitlesData(
                                rightTitles:
                                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles:
                                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (val, meta) => Text(
                                      val.toInt().toString(),
                                      style: const TextStyle(
                                          color: Color(0xFF849495),
                                          fontSize: 10,
                                          fontFamily: 'Geist'),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                      final idx = val.toInt();
                                      if (idx >= 0 && idx < months.length) {
                                        return Text(
                                          months[idx],
                                          style: const TextStyle(
                                              color: Color(0xFF849495),
                                              fontSize: 10,
                                              fontFamily: 'Geist'),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: controller.visitTrendSpots.toList(),
                                  isCurved: true,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF74F5FF), Color(0xFF7000FF)],
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF74F5FF).withOpacity(0.15),
                                        const Color(0xFF7000FF).withOpacity(0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Engagement Rate / Expense Breakdown (1/3 width)
                    Expanded(
                      flex: 1,
                      child: _buildChartCard(
                        title: 'Expense Breakdown',
                        subtitle: 'Weekly active users',
                        accentColor: const Color(0xFF7000FF),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 45,
                                  sections: controller.expenseBreakdown.entries.map((e) {
                                    final index =
                                        controller.expenseBreakdown.keys.toList().indexOf(e.key);
                                    final colors = [
                                      const Color(0xFF74F5FF),
                                      const Color(0xFFD1BCFF),
                                      const Color(0xFFFFB1C3),
                                    ];
                                    return PieChartSectionData(
                                      color: colors[index % colors.length],
                                      value: e.value,
                                      title:
                                          '${((e.value / (controller.totalExpensesThisMonth.value == 0 ? 1 : controller.totalExpensesThisMonth.value)) * 100).toStringAsFixed(0)}%',
                                      radius: 55,
                                      titleStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...controller.expenseBreakdown.entries.map((e) {
                              final index =
                                  controller.expenseBreakdown.keys.toList().indexOf(e.key);
                              final colors = [
                                const Color(0xFF74F5FF),
                                const Color(0xFFD1BCFF),
                                const Color(0xFFFFB1C3),
                              ];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colors[index % colors.length],
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                colors[index % colors.length].withOpacity(0.5),
                                            blurRadius: 6,
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        e.key,
                                        style: const TextStyle(
                                            color: Color(0xFFB9CACB),
                                            fontSize: 12,
                                            fontFamily: 'Geist'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Top Performers Table ──
                AdminGlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          color: Colors.white.withOpacity(0.02),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Top Performers',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Geist')),
                            Text(
                              '${controller.topPerformers.length} MRs',
                              style: const TextStyle(
                                  color: Color(0xFF849495), fontSize: 12, fontFamily: 'Geist'),
                            ),
                          ],
                        ),
                      ),
                      // Column headers
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
                          color: Colors.white.withOpacity(0.01),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 50, child: Text('RANK', style: _tableHeaderStyle)),
                            Expanded(flex: 3, child: Text('NAME', style: _tableHeaderStyle)),
                            Expanded(flex: 2, child: Text('TERRITORY', style: _tableHeaderStyle)),
                            Expanded(
                                flex: 1, child: Text('VISITS', style: _tableHeaderStyle)),
                            Expanded(
                                flex: 2, child: Text('AVG RATING', style: _tableHeaderStyle)),
                          ],
                        ),
                      ),
                      // Data Rows
                      ...controller.topPerformers.asMap().entries.map((entry) {
                        final i = entry.key;
                        final mr = entry.value;
                        final rankColors = [
                          const Color(0xFFFFD700),
                          const Color(0xFFC0C0C0),
                          const Color(0xFFCD7F32),
                        ];
                        final rankColor = i < 3 ? rankColors[i] : const Color(0xFF849495);

                        return Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.white.withOpacity(0.05))),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: rankColor.withOpacity(0.15),
                                    border:
                                        Border.all(color: rankColor.withOpacity(0.4)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '#${i + 1}',
                                      style: TextStyle(
                                          color: rankColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Geist'),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF74F5FF).withOpacity(0.5),
                                            const Color(0xFF7000FF).withOpacity(0.5),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          mr.name.isNotEmpty ? mr.name[0] : '?',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(mr.name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(mr.territoryId ?? 'Unassigned',
                                    style: const TextStyle(
                                        color: Color(0xFFB9CACB), fontSize: 13)),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(mr.totalVisits.toString(),
                                    style: const TextStyle(
                                        color: Color(0xFF74F5FF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Geist')),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    PhosphorIcon(
                                        PhosphorIcons.star(PhosphorIconsStyle.fill),
                                        color: const Color(0xFFFFD700),
                                        size: 14),
                                    const SizedBox(width: 4),
                                    Text(mr.avgRating.toStringAsFixed(1),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── KPI Bento Card ──
  Widget _buildKpiCard(String label, String value, String trend, bool isPositive,
      PhosphorIconData icon, Color accentColor) {
    return AdminGlassCard(
      child: Stack(
        children: [
          // Corner glow
          Positioned(
            top: -12,
            right: -12,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                      color: accentColor.withOpacity(0.2), blurRadius: 30, spreadRadius: 8)
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
                    Text(label,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                            color: Color(0xFFB9CACB),
                            fontFamily: 'Geist')),
                    PhosphorIcon(icon, size: 18, color: const Color(0xFF849495)),
                  ],
                ),
                const SizedBox(height: 10),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [accentColor, Colors.white],
                  ).createShader(bounds),
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1.0,
                        fontFamily: 'Geist'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    PhosphorIcon(
                      isPositive
                          ? PhosphorIcons.trendUp(PhosphorIconsStyle.bold)
                          : PhosphorIcons.trendDown(PhosphorIconsStyle.bold),
                      size: 13,
                      color: isPositive ? const Color(0xFF74F5FF) : const Color(0xFFFFB1C3),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Geist',
                        color: isPositive
                            ? const Color(0xFF74F5FF)
                            : const Color(0xFFFFB1C3),
                      ),
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

  // ── Chart Bento Card (with inner glow blobs) ──
  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Color accentColor,
    required Widget child,
  }) {
    return AdminGlassCard(
      child: Stack(
        children: [
          // Glow blobs
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7000FF).withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF7000FF).withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 10)
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Geist')),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: const TextStyle(
                                color: Color(0xFFB9CACB),
                                fontSize: 11,
                                fontFamily: 'Geist')),
                      ],
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(Icons.more_vert, color: Color(0xFFB9CACB), size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _tableHeaderStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    color: Color(0xFFB9CACB),
    fontFamily: 'Geist',
  );
}
