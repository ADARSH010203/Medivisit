import 'package:intl/intl.dart';

class PdfExportService {
  /// Generates a structured HTML/Print template matching the PDF specification
  /// containing UMAKIND logo, brand gradient header, bordered table with alternating rows,
  /// and "Generated on {date} by MediVisit Pro" footer.
  static String generateReportHtml({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
    Map<String, String>? kpis,
  }) {
    final now = DateFormat('MMMM d, yyyy - HH:mm').format(DateTime.now());

    final headerCols = headers.map((h) => '<th>$h</th>').join('');
    
    final bodyRows = rows.asMap().entries.map((entry) {
      final idx = entry.key;
      final row = entry.value;
      final bg = idx % 2 == 0 ? '#f8fafc' : '#ffffff';
      final cells = row.map((c) => '<td>${c ?? ''}</td>').join('');
      return '<tr style="background-color: $bg;">$cells</tr>';
    }).join('\n');

    final kpiCardsHtml = kpis == null
        ? ''
        : '''
        <div style="display: flex; gap: 16px; margin-bottom: 24px;">
          ${kpis.entries.map((e) => '''
            <div style="flex: 1; background: #f1f5f9; padding: 12px 16px; border-radius: 8px; border-left: 4px solid #0053D3;">
              <div style="font-size: 11px; color: #64748b; font-weight: 600; text-transform: uppercase;">${e.key}</div>
              <div style="font-size: 20px; color: #0f172a; font-weight: 700; margin-top: 4px;">${e.value}</div>
            </div>
          ''').join('')}
        </div>
        ''';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>$title</title>
  <style>
    body {
      font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
      margin: 0;
      padding: 0;
      color: #1e293b;
      background: #ffffff;
    }
    .header-bar {
      background: linear-gradient(90deg, #0053D3 0%, #44DDC1 100%);
      height: 8px;
    }
    .container {
      padding: 32px 40px;
    }
    .brand-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;
      border-bottom: 2px solid #e2e8f0;
      padding-bottom: 16px;
    }
    .brand-title {
      font-size: 24px;
      font-weight: 800;
      color: #0053D3;
      letter-spacing: -0.5px;
    }
    .sub-brand {
      font-size: 12px;
      color: #64748b;
      font-weight: 600;
    }
    .report-title {
      font-size: 20px;
      font-weight: 700;
      color: #0f172a;
      margin-bottom: 16px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 16px;
      font-size: 13px;
    }
    th {
      background-color: #0053D3;
      color: #ffffff;
      text-align: left;
      padding: 10px 14px;
      font-weight: 700;
    }
    td {
      padding: 10px 14px;
      border-bottom: 1px solid #e2e8f0;
    }
    .footer {
      margin-top: 40px;
      padding-top: 16px;
      border-top: 1px solid #cbd5e1;
      text-align: center;
      font-size: 11px;
      color: #64748b;
    }
  </style>
</head>
<body>
  <div class="header-bar"></div>
  <div class="container">
    <div class="brand-row">
      <div>
        <div class="brand-title">UMAKIND PHARMA</div>
        <div class="sub-brand">MediVisit Pro Analytics System</div>
      </div>
      <div style="text-align: right;">
        <div style="font-size: 12px; color: #64748b;">CONFIDENTIAL REPORT</div>
        <div style="font-size: 11px; color: #94a3b8;">Date: $now</div>
      </div>
    </div>

    <div class="report-title">$title</div>

    $kpiCardsHtml

    <table>
      <thead>
        <tr>$headerCols</tr>
      </thead>
      <tbody>
        $bodyRows
      </tbody>
    </table>

    <div class="footer">
      Generated on $now by MediVisit Pro
    </div>
  </div>
</body>
</html>
''';
  }
}
