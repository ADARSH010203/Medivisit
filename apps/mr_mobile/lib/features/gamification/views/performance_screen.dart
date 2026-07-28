import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/performance_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceScreen extends GetView<PerformanceController> {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: const Text('Performance Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.adminAccentStart));
        }

        final user = controller.currentUser.value;
        if (user == null) {
          return const Center(child: Text('User data not found', style: TextStyle(color: Colors.white54)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Visits',
                      value: '${user.totalVisits}',
                      subtitle: '+12% vs last month',
                      icon: Icons.store,
                      color: AppColors.adminAccentStart,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Avg Rating',
                      value: user.avgRating.toStringAsFixed(1),
                      subtitle: 'Top 10% in territory',
                      icon: Icons.star,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Score',
                      value: '${user.performancePercent.toInt()}%',
                      subtitle: 'Level 5',
                      icon: Icons.military_tech,
                      color: const Color(0xFFCD7F32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Attendance',
                      value: '95%',
                      subtitle: '2 days absent',
                      icon: Icons.fact_check,
                      color: const Color(0xFF00FF7F),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              Text(
                'Visits Trend',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.adminSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              return Text(days[value.toInt()], style: const TextStyle(color: Colors.white54, fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 3),
                          FlSpot(1, 5),
                          FlSpot(2, 4),
                          FlSpot(3, 7),
                          FlSpot(4, 6),
                        ],
                        isCurved: true,
                        color: AppColors.adminAccentStart,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.adminAccentStart.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
