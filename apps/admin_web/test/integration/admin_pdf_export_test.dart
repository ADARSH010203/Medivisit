import 'package:flutter_test/flutter_test.dart';
import 'package:core/services/csv_export_service.dart';
import 'package:core/services/pdf_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PDF & CSV Export Services Tests', () {
    test('Generate CSV report format correctly', () {
      final headers = ['Rank', 'Name', 'Territory', 'Visits'];
      final rows = [
        ['#1', 'Dr. Rahul Sharma', 'Mumbai West', 45],
        ['#2', 'Priya Patel', 'Delhi NCR', 38],
      ];

      final csv = CsvExportService.generateReportCsv(
        title: 'Test Monthly Report',
        headers: headers,
        rows: rows,
      );

      expect(csv.contains('UMAKIND PHARMA'), true);
      expect(csv.contains('Dr. Rahul Sharma'), true);
      expect(csv.contains('Mumbai West'), true);
    });

    test('Generate PDF HTML report format with UMAKIND branding & footer', () {
      final headers = ['Rank', 'Name', 'Visits'];
      final rows = [
        ['#1', 'Dr. Rahul Sharma', 45],
      ];

      final html = PdfExportService.generateReportHtml(
        title: 'Monthly Executive Analytics',
        headers: headers,
        rows: rows,
        kpis: {'Total Visits': '45'},
      );

      expect(html.contains('UMAKIND PHARMA'), true);
      expect(html.contains('Generated on'), true);
      expect(html.contains('by MediVisit Pro'), true);
      expect(html.contains('header-bar'), true);
    });
  });
}
