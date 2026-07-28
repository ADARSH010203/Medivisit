import 'package:intl/intl.dart';

class CsvExportService {
  static String generateReportCsv({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) {
    final StringBuffer buffer = StringBuffer();
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    
    // Title & Metadata
    buffer.writeln('# UMAKIND PHARMA - $title');
    buffer.writeln('# Generated on $now by MediVisit Pro');
    buffer.writeln();
    
    // Header Row
    buffer.writeln(headers.map(_sanitizeCsvCell).join(','));
    
    // Data Rows
    for (final row in rows) {
      buffer.writeln(row.map(_sanitizeCsvCell).join(','));
    }
    
    return buffer.toString();
  }

  static String _sanitizeCsvCell(dynamic cell) {
    if (cell == null) return '""';
    final str = cell.toString().replaceAll('"', '""');
    return '"$str"';
  }
}
