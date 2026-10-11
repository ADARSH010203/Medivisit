import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/performance_controller.dart';

class PerformanceScreen extends GetView<PerformanceController> {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsRegular.download),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: MeshGradientBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = controller.currentUser.value;
            if (user == null) {
              return const Center(child: Text('User data not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Tabs
                  Center(child: _buildPeriodToggle(controller, isDark)),
                  const SizedBox(height: 24),

                  // Hero Metric: Target Achievement
                  _buildTargetAchievementCard(isDark),
                  const SizedBox(height: 24),

                  // Comparison Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildComparisonCard(
                          title: 'Your Avg',
                          value: '${controller.yourAvgVisits.value.toInt()}',
                          unit: '/day',
                          trendText: '+${controller.avgVsLastMonth.value} vs last mo',
                          isPositive: true,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildComparisonCard(
                          title: 'Team Avg',
                          value: '${controller.teamAvgVisits.value}',
                          unit: '/day',
                          trendText: 'No change',
                          isPositive: null, // neutral
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bar Chart: Visits per Week
                  _buildVisitsBarChart(isDark),
                  const SizedBox(height: 32),

                  // Top Rated Doctors
                  Text(
                    'Top Rated Doctors',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF151C27),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...controller.topDoctors.map((doc) => _buildDoctorListItem(doc, isDark)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(PerformanceController ctrl, bool isDark) {
    final periods = ['week', 'month', 'quarter'];
    final labels = {'week': 'This Week', 'month': 'This Month', 'quarter': 'This Quarter'};

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((p) {
          final isSelected = ctrl.selectedPeriod.value == p;
          return GestureDetector(
            onTap: () => ctrl.changePeriod(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: isSelected
                    ? const LinearGradient(colors: [Color(0xFF1A6BFF), Color(0xFF68FADD)])
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF68FADD).withOpacity(0.4),
                          blurRadius: 15,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                labels[p]!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF424655)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTargetAchievementCard(bool isDark) {
    final percentage = controller.targetAchievement.value;
    
    return GlassCard(
      level: 2,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Achievement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF151C27),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 190,
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Ring
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      color: isDark ? const Color(0xFF2A313D) : const Color(0xFFE2E8F8),
                    ),
                  ),
                  // Progress Ring
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return const SweepGradient(
                          startAngle: -3.14 / 2, // -90 degrees
                          endAngle: 3 * 3.14 / 2, // 270 degrees
                          colors: [Color(0xFF1A6BFF), Color(0xFF68FADD)],
                        ).createShader(rect);
                      },
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  // Center Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF1A6BFF), Color(0xFF68FADD)],
                        ).createShader(bounds),
                        child: Text(
                          '${percentage.toInt()}%',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'ACHIEVED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: isDark ? Colors.white60 : const Color(0xFF727687),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required String value,
    required String unit,
    required String trendText,
    required bool? isPositive,
    required bool isDark,
  }) {
    Color trendColor;
    PhosphorIconData trendIcon;
    
    if (isPositive == true) {
      trendColor = const Color(0xFF006B5C); // Secondary
      trendIcon = PhosphorIconsRegular.trendUp;
    } else if (isPositive == false) {
      trendColor = const Color(0xFFBA1A1A); // Error
      trendIcon = PhosphorIconsRegular.trendDown;
    } else {
      trendColor = const Color(0xFF575C76); // Tertiary
      trendIcon = PhosphorIconsRegular.minus;
    }

    return GlassCard(
      level: 1,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF424655),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF151C27),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : const Color(0xFF727687),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              PhosphorIcon(trendIcon, size: 14, color: trendColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trendText,
                  style: TextStyle(
                    fontSize: 12,
                    color: trendColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsBarChart(bool isDark) {
    return GlassCard(
      level: 2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Visits per Week',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF151C27),
                ),
              ),
              PhosphorIcon(
                PhosphorIconsRegular.dotsThree,
                color: isDark ? Colors.white54 : const Color(0xFF727687),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 80,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF727687),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        );
                        final index = value.toInt();
                        if (index == 3) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Wk ${index + 1}', style: style.copyWith(color: const Color(0xFF1A6BFF))),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Wk ${index + 1}', style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(4, (index) {
                  final isCurrentWeek = index == 3;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: controller.weeklyVisits[index],
                        width: 32,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1A6BFF).withOpacity(isCurrentWeek ? 1.0 : 0.6),
                            const Color(0xFF68FADD).withOpacity(isCurrentWeek ? 1.0 : 0.6),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 80,
                          color: isDark ? const Color(0xFF2A313D) : const Color(0xFFDCE2F3),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorListItem(Map<String, dynamic> doc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        level: 1,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF2A313D) : const Color(0xFFDCE2F3),
              ),
              alignment: Alignment.center,
              child: Text(
                doc['initials'],
                style: const TextStyle(
                  color: Color(0xFF1A6BFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF151C27),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doc['specialty'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : const Color(0xFF727687),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '${doc['rating']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? Colors.white : const Color(0xFF151C27),
                  ),
                ),
                const SizedBox(width: 4),
                const PhosphorIcon(PhosphorIconsFill.star, color: Color(0xFFFFD700), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
