import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/formatters.dart';
import '../../transactions/domain/finance_transaction.dart';
import 'report_calculator.dart';

class ReportExportService {
  const ReportExportService._();

  static const PdfColor primaryColor = PdfColor.fromInt(0xFF2B2199);
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF6C5CE7);
  static const PdfColor incomeGreen = PdfColor.fromInt(0xFF00B894);
  static const PdfColor expenseRed = PdfColor.fromInt(0xFFFF7675);
  static const PdfColor neutralBg = PdfColor.fromInt(0xFFF8F9FD);
  static const PdfColor borderColor = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor textMutedColor = PdfColor.fromInt(0xFF64748B);

  static Future<Uint8List> generatePdf({
    required PeriodReport report,
    required List<FinanceTransaction> inRange,
    required String rangeLabel,
    required String periodName,
    required String userName,
    required String studentId,
  }) async {
    final pdf = pw.Document();

    final currency = Formatters.currentCurrency;
    final now = DateTime.now();
    final generatedDateStr = DateFormat('d MMM yyyy, HH:mm').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        header: (pw.Context context) => _buildPdfHeader(
          userName: userName,
          studentId: studentId,
          periodName: periodName,
          rangeLabel: rangeLabel,
          generatedDate: generatedDateStr,
        ),
        footer: (pw.Context context) => _buildPdfFooter(context),
        build: (pw.Context context) => [
          pw.SizedBox(height: 12),
          _buildSummaryCards(report, currency),
          pw.SizedBox(height: 16),
          if (report.categories.isNotEmpty) ...[
            _buildCategorySection(report, currency),
            pw.SizedBox(height: 16),
          ],
          if (report.paymentModes.any((m) => m.hasActivity)) ...[
            _buildPaymentModesSection(report, currency),
            pw.SizedBox(height: 16),
          ],
          _buildLedgerSection(inRange, currency),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfHeader({
    required String userName,
    required String studentId,
    required String periodName,
    required String rangeLabel,
    required String generatedDate,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: borderColor, width: 1.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 24,
                    height: 24,
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'P',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'PennyPal',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: neutralBg,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: borderColor),
                    ),
                    child: pw.Text(
                      'Official Statement',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: textMutedColor,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Student: $userName${studentId.isNotEmpty && studentId != 'N/A' ? ' ($studentId)' : ''}',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                '$periodName Statement',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                rangeLabel,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: textMutedColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Generated: $generatedDate',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: textMutedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'PennyPal • Student Budgeting, Savings & Financial Wellness',
            style: const pw.TextStyle(fontSize: 8, color: textMutedColor),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: textMutedColor),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCards(PeriodReport report, String currency) {
    final kept = report.keptFromIncome;
    final keptStr = kept == null ? 'N/A' : '${(kept * 100).toStringAsFixed(1)}%';

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: neutralBg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: borderColor),
      ),
      child: pw.Row(
        children: [
          _buildStatBox(
            'Total Income',
            '$currency ${report.income.toStringAsFixed(2)}',
            incomeGreen,
          ),
          _buildStatDivider(),
          _buildStatBox(
            'Total Expense',
            '$currency ${report.expense.toStringAsFixed(2)}',
            expenseRed,
          ),
          _buildStatDivider(),
          _buildStatBox(
            'Net Savings',
            '${report.net >= 0 ? '+' : '-'}$currency ${report.net.abs().toStringAsFixed(2)}',
            report.net >= 0 ? incomeGreen : expenseRed,
          ),
          _buildStatDivider(),
          _buildStatBox('Savings Rate', keptStr, primaryColor),
        ],
      ),
    );
  }

  static pw.Widget _buildStatBox(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 9, color: textMutedColor),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatDivider() {
    return pw.Container(
      width: 1,
      height: 28,
      color: borderColor,
    );
  }

  static pw.Widget _buildCategorySection(PeriodReport report, String currency) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SPENDING BY CATEGORY',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: textMutedColor,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: borderColor, width: 0.5),
          headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: primaryColor),
          cellStyle: const pw.TextStyle(fontSize: 8.5),
          cellPadding:
              const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          headers: ['Category', 'Amount ($currency)', 'Share of Spending'],
          data: [
            for (final cat in report.categories)
              [
                cat.category.label,
                cat.amount.toStringAsFixed(2),
                '${(cat.share * 100).toStringAsFixed(1)}%',
              ],
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentModesSection(
      PeriodReport report, String currency) {
    final activeModes = report.paymentModes.where((m) => m.hasActivity).toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PAYMENT METHODS & ACCOUNTS',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: textMutedColor,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: borderColor, width: 0.5),
          headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: secondaryColor),
          cellStyle: const pw.TextStyle(fontSize: 8.5),
          cellPadding:
              const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          headers: [
            'Payment Mode',
            'Inflow ($currency)',
            'Outflow ($currency)',
            'Net ($currency)',
          ],
          data: [
            for (final m in activeModes)
              [
                m.mode.label,
                '+${m.income.toStringAsFixed(2)}',
                '-${m.expense.toStringAsFixed(2)}',
                '${m.net >= 0 ? '+' : '-'}${m.net.abs().toStringAsFixed(2)}',
              ],
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildLedgerSection(
      List<FinanceTransaction> inRange, String currency) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'ITEMIZED TRANSACTIONS',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: textMutedColor,
              ),
            ),
            pw.Text(
              '${inRange.length} Records',
              style: const pw.TextStyle(fontSize: 9, color: textMutedColor),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        if (inRange.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: neutralBg,
              border: pw.Border.all(color: borderColor),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Center(
              child: pw.Text(
                'No transactions found for this period.',
                style: const pw.TextStyle(fontSize: 9, color: textMutedColor),
              ),
            ),
          )
        else
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: borderColor, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: primaryColor),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
            headers: [
              'Date',
              'Type',
              'Category',
              'Description',
              'Mode',
              'Amount ($currency)',
            ],
            data: [
              for (final t in inRange)
                [
                  DateFormat('dd-MM-yyyy').format(t.date),
                  t.isIncome ? 'Income' : 'Expense',
                  t.category?.label ?? (t.isIncome ? 'Inflow' : 'General'),
                  t.description.isEmpty ? '-' : t.description,
                  (t.paymentMode?.name ?? 'cash').toUpperCase(),
                  '${t.isIncome ? '+' : '-'}${t.amount.toStringAsFixed(2)}',
                ],
            ],
          ),
      ],
    );
  }

  static String generateCsv({
    required PeriodReport report,
    required List<FinanceTransaction> inRange,
    required String rangeLabel,
    required String periodName,
    required String userName,
    required String studentId,
  }) {
    final buffer = StringBuffer();
    final currency = Formatters.currentCurrency;
    buffer.writeln('PennyPal Student Financial Statement');
    buffer.writeln('Student Name,$userName');
    if (studentId.isNotEmpty && studentId != 'N/A') {
      buffer.writeln('Student ID,$studentId');
    }
    buffer.writeln('Period,$periodName ($rangeLabel)');
    buffer.writeln(
        'Generated On,${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buffer.writeln('Currency,$currency');
    buffer.writeln();
    buffer.writeln('--- FINANCIAL SUMMARY ---');
    buffer.writeln('Total Income,${report.income.toStringAsFixed(2)}');
    buffer.writeln('Total Expenses,${report.expense.toStringAsFixed(2)}');
    buffer.writeln('Net Savings,${report.net.toStringAsFixed(2)}');
    buffer.writeln(
        'Savings Rate,${report.keptFromIncome == null ? 'N/A' : (report.keptFromIncome! * 100).toStringAsFixed(1)}%');
    buffer.writeln('Total Records,${report.transactionCount}');
    buffer.writeln();
    buffer.writeln('--- CATEGORY BREAKDOWN ---');
    buffer.writeln('Category,Amount ($currency),Share %');
    for (final cat in report.categories) {
      buffer.writeln(
          '${cat.category.label},${cat.amount.toStringAsFixed(2)},${(cat.share * 100).toStringAsFixed(1)}%');
    }
    buffer.writeln();
    buffer.writeln('--- PAYMENT METHODS ---');
    buffer.writeln('Payment Mode,Inflow ($currency),Outflow ($currency),Net ($currency)');
    for (final m in report.paymentModes) {
      if (m.hasActivity) {
        buffer.writeln(
            '${m.mode.label},${m.income.toStringAsFixed(2)},${m.expense.toStringAsFixed(2)},${m.net.toStringAsFixed(2)}');
      }
    }
    buffer.writeln();
    buffer.writeln('--- ITEMIZED TRANSACTIONS ---');
    buffer.writeln('Date,Type,Category,Description,Payment Mode,Amount ($currency)');
    for (final t in inRange) {
      final dateStr = DateFormat('yyyy-MM-dd').format(t.date);
      final typeStr = t.isIncome ? 'Income' : 'Expense';
      final catStr =
          t.category?.label ?? (t.isIncome ? 'Inflow' : 'Uncategorized');
      final descStr = '"${t.description.replaceAll('"', '""')}"';
      final modeStr = t.paymentMode?.name ?? 'cash';
      final amountStr = t.amount.toStringAsFixed(2);
      buffer.writeln('$dateStr,$typeStr,$catStr,$descStr,$modeStr,$amountStr');
    }
    return buffer.toString();
  }

  static Future<void> exportPdf({
    required PeriodReport report,
    required List<FinanceTransaction> inRange,
    required String rangeLabel,
    required String periodName,
    required String userName,
    required String studentId,
  }) async {
    final bytes = await generatePdf(
      report: report,
      inRange: inRange,
      rangeLabel: rangeLabel,
      periodName: periodName,
      userName: userName,
      studentId: studentId,
    );

    final cleanPeriod =
        periodName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final filename = 'pennypal_statement_$cleanPeriod.pdf';

    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  static Future<void> printOrPreviewPdf({
    required PeriodReport report,
    required List<FinanceTransaction> inRange,
    required String rangeLabel,
    required String periodName,
    required String userName,
    required String studentId,
  }) async {
    final cleanPeriod =
        periodName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final filename = 'pennypal_statement_$cleanPeriod.pdf';

    await Printing.layoutPdf(
      name: filename,
      onLayout: (format) async => generatePdf(
        report: report,
        inRange: inRange,
        rangeLabel: rangeLabel,
        periodName: periodName,
        userName: userName,
        studentId: studentId,
      ),
    );
  }

  static Future<void> exportCsvFile({
    required PeriodReport report,
    required List<FinanceTransaction> inRange,
    required String rangeLabel,
    required String periodName,
    required String userName,
    required String studentId,
  }) async {
    final csv = generateCsv(
      report: report,
      inRange: inRange,
      rangeLabel: rangeLabel,
      periodName: periodName,
      userName: userName,
      studentId: studentId,
    );

    final cleanPeriod =
        periodName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final filename = 'pennypal_statement_$cleanPeriod.csv';

    final xFile = XFile.fromData(
      Uint8List.fromList(utf8.encode(csv)),
      mimeType: 'text/csv',
      name: filename,
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        subject: 'PennyPal Financial Statement ($periodName)',
      ),
    );
  }
}

