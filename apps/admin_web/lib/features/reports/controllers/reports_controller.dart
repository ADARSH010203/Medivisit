import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsController extends GetxController {
  final UserRepository _userRepo = Get.find<UserRepository>();
  
  final RxBool isLoading = true.obs;
  
  // KPIs
  final RxInt totalVisitsThisMonth = 0.obs;
  final RxInt totalMRs = 0.obs;
  final RxDouble avgVisitsPerMR = 0.0.obs;
  final RxDouble totalExpensesThisMonth = 0.0.obs;
  final RxInt pendingLeaves = 0.obs; // Mock for now if not injected
  final RxDouble attendanceRate = 0.0.obs; // Mock for now
  
  // Charts
  final RxList<FlSpot> visitTrendSpots = <FlSpot>[].obs;
  final RxMap<String, double> expenseBreakdown = <String, double>{}.obs;
  
  // Top Performers
  final RxList<MrUser> topPerformers = <MrUser>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      // Load all MRs
      final mrs = await _userRepo.getAllMrs();
      totalMRs.value = mrs.length;
      
      // Calculate total visits this month (simulated aggregated fetch for now)
      // In production we'd use a cloud function or proper aggregation query
      int totalVisits = 0;
      
      for (var mr in mrs) {
        totalVisits += mr.totalVisits; // Simplification
      }
      totalVisitsThisMonth.value = totalVisits; // In real app, filter by month
      avgVisitsPerMR.value = mrs.isEmpty ? 0 : totalVisits / mrs.length;
      
      // Mock expense and attendance data
      totalExpensesThisMonth.value = 45500.0;
      pendingLeaves.value = 3;
      attendanceRate.value = 92.5;

      // Mock Visit Trend (Last 6 months)
      visitTrendSpots.value = const [
        FlSpot(1, 120),
        FlSpot(2, 150),
        FlSpot(3, 110),
        FlSpot(4, 180),
        FlSpot(5, 210),
        FlSpot(6, 195),
      ];
      
      // Mock Expense Breakdown
      expenseBreakdown.value = {
        'Travel': 25000,
        'Food': 12000,
        'Accommodation': 8500,
      };

      // Top Performers
      final sortedMrs = List<MrUser>.from(mrs);
      sortedMrs.sort((a, b) => b.totalVisits.compareTo(a.totalVisits));
      topPerformers.value = sortedMrs.take(5).toList();

    } catch (e) {
      Get.snackbar('Error', 'Failed to load report data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void exportCsv() {
    final headers = ['Rank', 'Name', 'Territory', 'Visits', 'Avg Rating'];
    final rows = topPerformers.asMap().entries.map((entry) {
      final mr = entry.value;
      return [
        '#${entry.key + 1}',
        mr.name,
        mr.territoryId ?? 'Unassigned',
        mr.totalVisits,
        mr.avgRating.toStringAsFixed(1),
      ];
    }).toList();

    final csvContent = CsvExportService.generateReportCsv(
      title: 'Top Performers & Monthly Visit Report',
      headers: headers,
      rows: rows,
    );

    Get.snackbar(
      'CSV Export Generated',
      'Generated CSV report (${csvContent.length} bytes)',
      backgroundColor: const Color(0xFF006B5C),
      colorText: Colors.white,
    );
  }

  void exportPdf() {
    final headers = ['Rank', 'Name', 'Territory', 'Visits', 'Avg Rating'];
    final rows = topPerformers.asMap().entries.map((entry) {
      final mr = entry.value;
      return [
        '#${entry.key + 1}',
        mr.name,
        mr.territoryId ?? 'Unassigned',
        mr.totalVisits,
        mr.avgRating.toStringAsFixed(1),
      ];
    }).toList();

    final kpis = {
      'Total Visits': totalVisitsThisMonth.value.toString(),
      'Avg Visits/MR': avgVisitsPerMR.value.toStringAsFixed(1),
      'Total Expenses': '₹${totalExpensesThisMonth.value.toStringAsFixed(0)}',
      'Attendance Rate': '${attendanceRate.value}%',
    };

    final htmlContent = PdfExportService.generateReportHtml(
      title: 'Monthly Executive Analytics & Performance Report',
      headers: headers,
      rows: rows,
      kpis: kpis,
    );

    Get.snackbar(
      'PDF Export Ready',
      'Generated branded PDF report (${htmlContent.length} bytes)',
      backgroundColor: const Color(0xFF0053D3),
      colorText: Colors.white,
    );
  }
}
