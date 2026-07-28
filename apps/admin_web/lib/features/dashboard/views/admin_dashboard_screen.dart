import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
class AdminDashboardController extends GetxController {
  final RxInt totalMRs = 42.obs;
  final RxInt activeDoctors = 1250.obs;
  final RxInt visitsToday = 184.obs;
  final RxInt pendingVerifications = 3.obs;
  
  // Mock data for charts
  final visitTrendSpots = const [
    FlSpot(0, 150),
    FlSpot(1, 230),
    FlSpot(2, 180),
    FlSpot(3, 300),
    FlSpot(4, 250),
    FlSpot(5, 400),
  ].obs;
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by Shell
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dashboard Overview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Row(
              children: [
                Expanded(
                  child: KpiTile(
                    title: 'Active MRs',
                    value: controller.totalMRs.value.toString(),
                    icon: PhosphorIcons.users(PhosphorIconsStyle.duotone),
                    trend: '+12%',
                    isPositiveTrend: true,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: KpiTile(
                    title: 'Total Doctors',
                    value: controller.activeDoctors.value.toString(),
                    icon: PhosphorIcons.stethoscope(PhosphorIconsStyle.duotone),
                    trend: '+5%',
                    isPositiveTrend: true,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: KpiTile(
                    title: 'Visits Today',
                    value: controller.visitsToday.value.toString(),
                    icon: PhosphorIcons.personSimpleWalk(PhosphorIconsStyle.duotone),
                    trend: '-2%',
                    isPositiveTrend: false,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: AdminGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pending Actions',
                              style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            PhosphorIcon(PhosphorIcons.warningCircle(PhosphorIconsStyle.duotone), color: AppColors.warning, size: 20),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${controller.pendingVerifications.value} Verifications',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Get.toNamed('/admin/mrs/verification');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            alignment: Alignment.centerLeft,
                          ),
                          child: const Text('Review Now →', style: TextStyle(color: AppColors.adminAccentStart)),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: AdminGlassCard(
                    height: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Visit Trend (Last 6 Months)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                                  dotData: const FlDotData(show: false),
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
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: AdminGlassCard(
                    height: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top Performers', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(child: Text('${index + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('MR Name ${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: (5 - index) / 5,
                                        backgroundColor: Colors.grey[800],
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text('${(5 - index) * 45} Visits', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
          ],
        ),
      ),
    );
  }
}
