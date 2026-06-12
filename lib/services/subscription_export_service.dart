import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:intl/intl.dart';
import 'package:punch_app_admin/core/helper/download_helper_stub.dart'
    if (dart.library.html) 'package:punch_app_admin/core/helper/download_helper.dart';
import 'package:punch_app_admin/core/helper/file_helper_native.dart';

// ─── PDF ─────────────────────────────────────────────────────────────────────
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ─── Excel ───────────────────────────────────────────────────────────────────
import 'package:excel/excel.dart';

class SubscriptionExportService {
  // ─────────────────────────── helpers ──────────────────────────────────────

  static String _fmtDate(dynamic date) {
    if (date == null) return '—';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date.toString()));
    } catch (_) {
      return '—';
    }
  }

  static String _fmtDateLong(dynamic date) {
    if (date == null) return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date.toString()));
    } catch (_) {
      return '—';
    }
  }

  static String _daysLeft(dynamic expiryDate) {
    if (expiryDate == null) return '—';
    try {
      final expiry = DateTime.parse(expiryDate.toString());
      final diff = expiry.difference(DateTime.now()).inDays;
      if (diff < 0) return 'Expired';
      if (diff == 0) return 'Expires today';
      return '$diff days left';
    } catch (_) {
      return '—';
    }
  }

  static bool _isExpired(dynamic expiryDate) {
    if (expiryDate == null) return false;
    try {
      return DateTime.parse(expiryDate.toString()).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  static bool _isExpiringSoon(dynamic expiryDate) {
    if (expiryDate == null) return false;
    try {
      final diff = DateTime.parse(expiryDate.toString())
          .difference(DateTime.now())
          .inDays;
      return diff >= 0 && diff <= 7;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PDF EXPORT
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<void> exportPDF({
    required BuildContext context,
    required List<Map<String, dynamic>> rows,
    required String exportedBy,
  }) async {
    final pdf = pw.Document();

    // ── colours ────────────────────────────────────────────────────────────
    const headerBg    = PdfColor(0.118, 0.251, 0.686); // #1E40AF
    const rowAltBg    = PdfColor(0.973, 0.980, 0.988);
    const successClr  = PdfColor(0.086, 0.639, 0.369);
    const errorClr    = PdfColor(0.863, 0.149, 0.149);
    const warnClr     = PdfColor(0.961, 0.620, 0.043);
    const mutedClr    = PdfColor(0.580, 0.639, 0.722);
    const txtPrimary  = PdfColor(0.059, 0.090, 0.165);
    const txtSec      = PdfColor(0.282, 0.337, 0.412);
    const greenBadge  = PdfColor(0.863, 0.988, 0.902);
    const redBadge    = PdfColor(0.995, 0.882, 0.882);
    const yellowBadge = PdfColor(0.996, 0.953, 0.796);
    const greyBadge   = PdfColor(0.930, 0.930, 0.930);

    final planColorMap = <String, PdfColor>{
      'trial':   const PdfColor(0.545, 0.361, 0.965),
      'basic':   const PdfColor(0.024, 0.714, 0.765),
      'pro':     const PdfColor(0.851, 0.467, 0.043),
      'premium': const PdfColor(0.424, 0.388, 1.0),
    };

    final font     = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // ── stats ──────────────────────────────────────────────────────────────
    final totalActive   = rows.where((r) => r['status'] == 'active').length;
    final totalExpired  = rows.where((r) => _isExpired(r['expiry_date'])).length;
    final totalExpiring = rows.where((r) => _isExpiringSoon(r['expiry_date'])).length;
    final totalRevenue  = rows.fold<num>(
      0, (sum, r) => sum + (r['amount'] as num? ?? 0));

    final generatedAt = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),

        // ── header ─────────────────────────────────────────────────────────
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Brand banner
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const pw.BoxDecoration(
                color: headerBg,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PUNCH APP ADMIN',
                          style: pw.TextStyle(
                              font: fontBold, fontSize: 13,
                              color: PdfColors.white)),
                      pw.SizedBox(height: 2),
                      pw.Text('Subscription Report',
                          style: pw.TextStyle(
                              font: font, fontSize: 9,
                              color: PdfColors.white)),
                    ],
                  ),
                  pw.Text('Generated: $generatedAt',
                      style: pw.TextStyle(
                          font: fontBold, fontSize: 8,
                          color: PdfColors.white)),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // Stat cards
            pw.Row(
              children: [
                _statCard('Total', '${rows.length}', fontBold, font),
                pw.SizedBox(width: 8),
                _statCard('Active', '$totalActive', fontBold, font,
                    valuColor: successClr, bg: greenBadge),
                pw.SizedBox(width: 8),
                _statCard('Expiring', '$totalExpiring', fontBold, font,
                    valuColor: warnClr, bg: yellowBadge),
                pw.SizedBox(width: 8),
                _statCard('Expired', '$totalExpired', fontBold, font,
                    valuColor: errorClr, bg: redBadge),
                pw.SizedBox(width: 8),
                _statCard('Revenue', 'Rs.$totalRevenue', fontBold, font),
              ],
            ),
            pw.SizedBox(height: 4),
          ],
        ),

        // ── footer ─────────────────────────────────────────────────────────
        footer: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Exported by: $exportedBy',
                style: pw.TextStyle(
                    font: font, fontSize: 7.5, color: PdfColors.grey500),
              ),
              pw.Text(
                'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: pw.TextStyle(
                    font: font, fontSize: 7.5, color: PdfColors.grey500),
              ),
            ],
          ),
        ),

        build: (_) => [
          pw.SizedBox(height: 10),

          // ── Table header ─────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: const pw.BoxDecoration(
              color: headerBg,
              borderRadius: pw.BorderRadius.only(
                topLeft:  pw.Radius.circular(6),
                topRight: pw.Radius.circular(6),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(flex: 4, child: _th('Company', fontBold)),
                pw.Expanded(flex: 2, child: _th('Plan', fontBold, center: true)),
                pw.Expanded(flex: 2, child: _th('Start Date', fontBold, center: true)),
                pw.Expanded(flex: 2, child: _th('Expiry Date', fontBold, center: true)),
                pw.Expanded(flex: 1, child: _th('Users', fontBold, center: true)),
                pw.Expanded(flex: 2, child: _th('Amount', fontBold, center: true)),
                pw.Expanded(flex: 2, child: _th('Status', fontBold, center: true)),
                pw.Expanded(flex: 2, child: _th('Days Left', fontBold, center: true)),
              ],
            ),
          ),

          // ── Data rows ────────────────────────────────────────────────────
          ...rows.asMap().entries.map((entry) {
            final idx      = entry.key;
            final row      = entry.value;
            final company  = row['companies'] as Map<String, dynamic>?;
            final plan     = (row['plan'] ?? 'trial').toString().toLowerCase();
            final status   = (row['status'] ?? 'active').toString();
            final isExp    = _isExpired(row['expiry_date']);
            final isSoon   = _isExpiringSoon(row['expiry_date']);
            final bg       = idx.isEven ? PdfColors.white : rowAltBg;

            final planClr  = planColorMap[plan] ?? headerBg;
            final planBg   = PdfColor(
              planClr.red * 0.15 + 0.85,
              planClr.green * 0.15 + 0.85,
              planClr.blue * 0.15 + 0.85,
            );

            PdfColor statusClr;
            PdfColor statusBg;
            String statusTxt;
            if (isExp) {
              statusClr = errorClr; statusBg = redBadge; statusTxt = 'Expired';
            } else if (status == 'active') {
              statusClr = successClr; statusBg = greenBadge; statusTxt = 'Active';
            } else {
              statusClr = warnClr; statusBg = yellowBadge; statusTxt = status;
            }

            PdfColor daysClr;
            PdfColor daysBg;
            if (isExp) {
              daysClr = errorClr; daysBg = redBadge;
            } else if (isSoon) {
              daysClr = warnClr; daysBg = yellowBadge;
            } else {
              daysClr = successClr; daysBg = greenBadge;
            }

            return pw.Container(
              decoration: pw.BoxDecoration(
                color: bg,
                border: const pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200),
                  left:   pw.BorderSide(color: PdfColors.grey200),
                  right:  pw.BorderSide(color: PdfColors.grey200),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Company
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(company?['name']?.toString() ?? '—',
                            style: pw.TextStyle(
                                font: fontBold, fontSize: 9,
                                color: txtPrimary)),
                        if ((company?['email'] ?? '').toString().isNotEmpty)
                          pw.Text(company!['email'].toString(),
                              style: pw.TextStyle(
                                  font: font, fontSize: 7.5,
                                  color: mutedClr)),
                      ],
                    ),
                  ),
                  // Plan badge
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: planBg,
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Text(
                          plan.toUpperCase(),
                          style: pw.TextStyle(
                              font: fontBold, fontSize: 8,
                              color: planClr),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  // Start Date
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text(
                        _fmtDate(row['start_date']),
                        style: pw.TextStyle(
                            font: font, fontSize: 8,
                            color: txtSec),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                  // Expiry Date
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text(
                        _fmtDate(row['expiry_date']),
                        style: pw.TextStyle(
                            font: fontBold, fontSize: 8,
                            color: isExp ? errorClr : txtSec),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                  // Users
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                      child: pw.Text(
                        '${row['user_limit'] ?? 0}',
                        style: pw.TextStyle(
                            font: fontBold, fontSize: 9,
                            color: txtPrimary),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                  // Amount — use "Rs." instead of "₹" (Helvetica lacks the glyph)
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Text(
                        'Rs.${row['amount'] ?? 0}',
                        style: pw.TextStyle(
                            font: fontBold, fontSize: 9,
                            color: txtPrimary),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                  // Status badge
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: statusBg,
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Text(
                          statusTxt,
                          style: pw.TextStyle(
                              font: fontBold, fontSize: 7.5,
                              color: statusClr),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  // Days left badge
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: daysBg,
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Text(
                          _daysLeft(row['expiry_date']),
                          style: pw.TextStyle(
                              font: fontBold, fontSize: 7.5,
                              color: daysClr),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          pw.SizedBox(height: 16),

          // ── Legend ────────────────────────────────────────────────────────
          pw.Row(
            children: [
              _dot(successClr), pw.SizedBox(width: 4),
              pw.Text('Active   ', style: pw.TextStyle(font: font, fontSize: 8, color: mutedClr)),
              _dot(warnClr), pw.SizedBox(width: 4),
              pw.Text('Expiring Soon   ', style: pw.TextStyle(font: font, fontSize: 8, color: mutedClr)),
              _dot(errorClr), pw.SizedBox(width: 4),
              pw.Text('Expired', style: pw.TextStyle(font: font, fontSize: 8, color: mutedClr)),
            ],
          ),
        ],
      ),
    );

    final filename =
        'Subscriptions_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.pdf';
    final pdfBytes = await pdf.save();

    await _saveAndOpen(
      context: context,
      bytes: Uint8List.fromList(pdfBytes),
      filename: filename,
      mimeType: 'application/pdf',
    );
  }

  // ── PDF widget helpers ─────────────────────────────────────────────────────

  static pw.Widget _statCard(
      String label, String value, pw.Font fontBold, pw.Font font,
      {PdfColor? valuColor, PdfColor? bg}) {
    const defaultTxt = PdfColor(0.059, 0.090, 0.165);
    const defaultBg  = PdfColors.grey100;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: bg ?? defaultBg,
        borderRadius: pw.BorderRadius.circular(5),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(value,
              style: pw.TextStyle(
                  font: fontBold, fontSize: 11,
                  color: valuColor ?? defaultTxt)),
          pw.Text(label,
              style: pw.TextStyle(
                  font: font, fontSize: 7.5,
                  color: const PdfColor(0.580, 0.639, 0.722))),
        ],
      ),
    );
  }

  static pw.Widget _th(String label, pw.Font font, {bool center = false}) {
    return pw.Text(label,
        style: pw.TextStyle(font: font, fontSize: 8.5, color: PdfColors.white),
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left);
  }

  static pw.Widget _dot(PdfColor color) {
    return pw.Container(
      width: 7, height: 7,
      decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  EXCEL EXPORT
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<void> exportExcel({
    required BuildContext context,
    required List<Map<String, dynamic>> rows,
    required String exportedBy,
  }) async {
    final excel = Excel.createExcel();

    final sheet = excel['Subscriptions'];
    _writeSubscriptionSheet(sheet, rows, exportedBy);

    for (final defaultName in ['Sheet1', 'FlutterExcel']) {
      if (excel.sheets.containsKey(defaultName)) {
        excel.delete(defaultName);
      }
    }

    final bytes = excel.encode();
    if (bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate Excel file'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final filename =
        'Subscriptions_${DateFormat("ddMMyyyy_HHmm").format(DateTime.now())}.xlsx';

    await _saveAndOpen(
      context: context,
      bytes: Uint8List.fromList(bytes),
      filename: filename,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  // ─── Sheet writer ──────────────────────────────────────────────────────────

  static void _writeSubscriptionSheet(
    Sheet sheet,
    List<Map<String, dynamic>> rows,
    String exportedBy,
  ) {
    final totalActive   = rows.where((r) => r['status'] == 'active').length;
    final totalExpired  = rows.where((r) => _isExpired(r['expiry_date'])).length;
    final totalExpiring = rows.where((r) => _isExpiringSoon(r['expiry_date'])).length;
    final totalRevenue  = rows.fold<num>(
        0, (sum, r) => sum + (r['amount'] as num? ?? 0));
    final generatedAt   =
        DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    // ── Row 0: title ─────────────────────────────────────────────────────────
    final t = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    t.value = TextCellValue('PUNCH APP ADMIN  —  SUBSCRIPTION REPORT');
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0),
    );
    t.cellStyle = CellStyle(
      bold: true,
      fontSize: 13,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#1E40AF'),
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Left,
    );
    sheet.setRowHeight(0, 32);

    // ── Row 1: stats summary ──────────────────────────────────────────────────
    final statsText =
        'Records: ${rows.length}     Active: $totalActive     '
        'Expiring Soon: $totalExpiring     Expired: $totalExpired     '
        'Total Revenue: ₹$totalRevenue     '
        'Generated: $generatedAt     Exported by: $exportedBy';

    final s = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1));
    s.value = TextCellValue(statsText);
    s.cellStyle = CellStyle(
      italic: true,
      fontSize: 9,
      fontColorHex: ExcelColor.fromHexString('#475569'),
      backgroundColorHex: ExcelColor.fromHexString('#EEF2FF'),
      verticalAlign: VerticalAlign.Center,
    );
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 1),
    );
    sheet.setRowHeight(1, 22);

    // ── Row 2: spacer ─────────────────────────────────────────────────────────
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .value = TextCellValue('');
    sheet.setRowHeight(2, 8);

    // ── Row 3: column headers ─────────────────────────────────────────────────
    const headers = [
      'Company Name',
      'Email',
      'Plan',
      'Start Date',
      'Expiry Date',
      'User Limit',
      'Amount (₹)',
      'Status',
      'Days Left',
    ];
    for (var c = 0; c < headers.length; c++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 3));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = CellStyle(
        bold: true,
        fontSize: 10,
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('#1E40AF'),
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: c >= 3 ? HorizontalAlign.Center : HorizontalAlign.Left,
        bottomBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.white,
        ),
        rightBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.white,
        ),
      );
    }
    sheet.setRowHeight(3, 26);

    // ── Plan colour map ────────────────────────────────────────────────────────
    const planFgHex = {
      'trial':   '#7C3AED',
      'basic':   '#0891B2',
      'pro':     '#D97706',
      'premium': '#4F46E5',
    };
    const planBgHex = {
      'trial':   '#EDE9FE',
      'basic':   '#CFFAFE',
      'pro':     '#FEF3C7',
      'premium': '#EEF2FF',
    };

    // ── Rows 4+: data ─────────────────────────────────────────────────────────
    for (var i = 0; i < rows.length; i++) {
      final row     = rows[i];
      final company = row['companies'] as Map<String, dynamic>?;
      final plan    = (row['plan'] ?? 'trial').toString().toLowerCase();
      final status  = (row['status'] ?? 'active').toString();
      final isExp   = _isExpired(row['expiry_date']);
      final isSoon  = _isExpiringSoon(row['expiry_date']);
      final r       = 4 + i;

      final rowBg = i.isEven
          ? ExcelColor.fromHexString('#FFFFFF')
          : ExcelColor.fromHexString('#F8FAFC');

      final borderColor = ExcelColor.fromHexString('#E2E8F0');
      final cellBorder  = Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: borderColor,
      );

      void writeCell(
        int col,
        String val, {
        bool bold = false,
        String fgHex = '#0F172A',
        String? bgHex,
        HorizontalAlign halign = HorizontalAlign.Left,
      }) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: r));
        cell.value = TextCellValue(val);
        cell.cellStyle = CellStyle(
          bold: bold,
          fontSize: 10,
          backgroundColorHex:
              bgHex != null ? ExcelColor.fromHexString(bgHex) : rowBg,
          fontColorHex: ExcelColor.fromHexString(fgHex),
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: halign,
          topBorder: cellBorder,
          bottomBorder: cellBorder,
          leftBorder: cellBorder,
          rightBorder: cellBorder,
        );
      }

      // Company name
      writeCell(0, company?['name']?.toString() ?? '—', bold: true);
      // Email
      writeCell(1, company?['email']?.toString() ?? '—',
          fgHex: '#64748B');
      // Plan badge
      writeCell(
        2,
        plan.toUpperCase(),
        bold: true,
        fgHex: planFgHex[plan] ?? '#1E40AF',
        bgHex: planBgHex[plan] ?? '#EEF2FF',
        halign: HorizontalAlign.Center,
      );
      // Dates
      writeCell(3, _fmtDateLong(row['start_date']),
          fgHex: '#475569', halign: HorizontalAlign.Center);
      writeCell(4, _fmtDateLong(row['expiry_date']),
          fgHex: isExp ? '#DC2626' : '#475569',
          bold: isExp,
          halign: HorizontalAlign.Center);
      // Users
      writeCell(5, '${row['user_limit'] ?? 0}',
          halign: HorizontalAlign.Center,
          fgHex: '#0F172A');
      // Amount
      writeCell(6, '₹${row['amount'] ?? 0}',
          bold: true, halign: HorizontalAlign.Center);

      // Status — coloured cell
      String statusTxt;
      String statusFg;
      String statusBg;
      if (isExp) {
        statusTxt = 'Expired'; statusFg = '#DC2626'; statusBg = '#FEE2E2';
      } else if (status == 'active') {
        statusTxt = 'Active'; statusFg = '#16A34A'; statusBg = '#DCFCE7';
      } else {
        statusTxt = status.toUpperCase();
        statusFg = '#D97706'; statusBg = '#FEF3C7';
      }
      writeCell(7, statusTxt,
          bold: true, fgHex: statusFg, bgHex: statusBg,
          halign: HorizontalAlign.Center);

      // Days left — coloured cell
      String daysFg;
      String daysBg;
      if (isExp) {
        daysFg = '#DC2626'; daysBg = '#FEE2E2';
      } else if (isSoon) {
        daysFg = '#D97706'; daysBg = '#FEF3C7';
      } else {
        daysFg = '#16A34A'; daysBg = '#DCFCE7';
      }
      writeCell(8, _daysLeft(row['expiry_date']),
          bold: true, fgHex: daysFg, bgHex: daysBg,
          halign: HorizontalAlign.Center);

      sheet.setRowHeight(r, 22);
    }

    // ── Column widths ─────────────────────────────────────────────────────────
    sheet.setColumnWidth(0, 28);  // Company Name
    sheet.setColumnWidth(1, 32);  // Email
    sheet.setColumnWidth(2, 12);  // Plan
    sheet.setColumnWidth(3, 16);  // Start Date
    sheet.setColumnWidth(4, 16);  // Expiry Date
    sheet.setColumnWidth(5, 12);  // User Limit
    sheet.setColumnWidth(6, 14);  // Amount
    sheet.setColumnWidth(7, 12);  // Status
    sheet.setColumnWidth(8, 14);  // Days Left
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SHARED SAVE + OPEN
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<void> _saveAndOpen({
    required BuildContext context,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    if (kIsWeb) {
      triggerWebDownload(bytes: bytes, filename: filename, mimeType: mimeType);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading $filename...'),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      await saveToDownloadsAndShare(bytes, filename);
    }
  }
}