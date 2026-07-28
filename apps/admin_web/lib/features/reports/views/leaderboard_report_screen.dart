import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/leaderboard_report_controller.dart';
import 'package:core/core.dart';

class LeaderboardReportScreen extends GetView<LeaderboardReportController> {
  const LeaderboardReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: const Text('MR Leaderboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Performers',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.adminSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedPeriod.value,
                      dropdownColor: AppColors.adminSurface,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      ],
                      onChanged: (val) {
                        if (val != null) controller.changePeriod(val);
                      },
                    ),
                  ),
                )),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.adminAccentStart));
                }
                if (controller.leaderboard.isEmpty) {
                  return const Center(child: Text('No data found.', style: TextStyle(color: Colors.white54)));
                }

                return AdminGlassCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
                      child: DataTable(
                        headingTextStyle: const TextStyle(color: AppColors.adminAccentStart, fontWeight: FontWeight.bold),
                        dataTextStyle: const TextStyle(color: Colors.white),
                        columns: const [
                          DataColumn(label: Text('Rank')),
                          DataColumn(label: Text('MR Name')),
                          DataColumn(label: Text('Territory')),
                          DataColumn(label: Text('Score')),
                        ],
                        rows: controller.leaderboard.map((entry) {
                          return DataRow(
                            cells: [
                              DataCell(Text('#${entry.rank}')),
                              DataCell(Text(entry.name)),
                              DataCell(Text(entry.territory)),
                              DataCell(Text('${entry.score}')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
