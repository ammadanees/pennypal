import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../auth/data/auth_providers.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../domain/report_calculator.dart';
import '../domain/report_export_service.dart';

class StatementPreviewSheet extends ConsumerStatefulWidget {
  const StatementPreviewSheet({
    super.key,
    required this.allTransactions,
    required this.period,
  });

  final List<FinanceTransaction> allTransactions;
  final ReportPeriod period;

  static Future<void> show(
    BuildContext context, {
    required List<FinanceTransaction> allTransactions,
    required ReportPeriod period,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => StatementPreviewSheet(
        allTransactions: allTransactions,
        period: period,
      ),
    );
  }

  @override
  ConsumerState<StatementPreviewSheet> createState() =>
      _StatementPreviewSheetState();
}

class _StatementPreviewSheetState extends ConsumerState<StatementPreviewSheet> {
  bool _isSavingToCloud = false;
  bool _savedToCloud = false;
  bool _isExportingPdf = false;
  bool _isExportingCsv = false;

  Future<void> _exportPdf(
    PeriodReport report,
    List<FinanceTransaction> inRange,
    String rangeLabel,
    String userName,
    String studentId,
  ) async {
    setState(() => _isExportingPdf = true);
    try {
      await ReportExportService.exportPdf(
        report: report,
        inRange: inRange,
        rangeLabel: rangeLabel,
        periodName: widget.period.label,
        userName: userName,
        studentId: studentId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('PDF statement generated and shared successfully!'),
              ),
            ],
          ),
          backgroundColor: AppAccents.green.color,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not export PDF: $e'),
          backgroundColor: AppAccents.coral.color,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  Future<void> _printOrPreviewPdf(
    PeriodReport report,
    List<FinanceTransaction> inRange,
    String rangeLabel,
    String userName,
    String studentId,
  ) async {
    try {
      await ReportExportService.printOrPreviewPdf(
        report: report,
        inRange: inRange,
        rangeLabel: rangeLabel,
        periodName: widget.period.label,
        userName: userName,
        studentId: studentId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not preview PDF: $e'),
          backgroundColor: AppAccents.coral.color,
        ),
      );
    }
  }

  Future<void> _exportCsv(
    PeriodReport report,
    List<FinanceTransaction> inRange,
    String rangeLabel,
    String userName,
    String studentId,
  ) async {
    setState(() => _isExportingCsv = true);
    try {
      await ReportExportService.exportCsvFile(
        report: report,
        inRange: inRange,
        rangeLabel: rangeLabel,
        periodName: widget.period.label,
        userName: userName,
        studentId: studentId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.table_view_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('CSV statement file exported successfully!'),
              ),
            ],
          ),
          backgroundColor: AppAccents.green.color,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not export CSV file: $e'),
          backgroundColor: AppAccents.coral.color,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExportingCsv = false);
    }
  }

  Future<void> _copyCsv(
    PeriodReport report,
    List<FinanceTransaction> inRange,
    String rangeLabel,
    String userName,
    String studentId,
  ) async {
    final csv = ReportExportService.generateCsv(
      report: report,
      inRange: inRange,
      rangeLabel: rangeLabel,
      periodName: widget.period.label,
      userName: userName,
      studentId: studentId,
    );
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Financial statement CSV copied to clipboard! Ready to paste into Excel or Google Sheets.',
              ),
            ),
          ],
        ),
        backgroundColor: AppAccents.green.color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _saveToReportsEntity(
    PeriodReport report,
    String rangeLabel,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSavingToCloud = true);
    try {
      final reportRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reports')
          .doc();

      await reportRef.set({
        'reportId': reportRef.id,
        'userId': uid,
        'reportType': widget.period.label,
        'dateRange': rangeLabel,
        'generatedOn': FieldValue.serverTimestamp(),
        'income': report.income,
        'expense': report.expense,
        'net': report.net,
        'transactionCount': report.transactionCount,
        'currency': Formatters.currentCurrency,
      });

      if (!mounted) return;
      setState(() {
        _isSavingToCloud = false;
        _savedToCloud = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Statement archived to cloud reports successfully!'),
          backgroundColor: AppAccents.green.color,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingToCloud = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not archive report: $e'),
          backgroundColor: AppAccents.coral.color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final now = DateTime.now();
    final range = widget.period.range(now);
    final report = ReportCalculator.forRange(widget.allTransactions, range);
    final inRange = widget.allTransactions
        .where((tr) => range.contains(tr.date))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final user = ref.watch(authStateProvider).asData?.value;
    final userName = user?.fullName ?? 'Student';
    final studentId = user?.studentId ?? 'N/A';
    final rangeLabel =
        '${DateFormat('d MMM yyyy').format(range.start)} - ${DateFormat('d MMM yyyy').format(range.end)}';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: c.primary,
                  size: 28,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Statement',
                      style: t.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'PennyPal • Academic Edition',
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          AppSpacing.vMd,

          // Metadata Card
          AppCard(
            color: c.surface,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Student:', style: t.bodySmall),
                    Text(
                      userName,
                      style:
                          t.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (studentId != 'N/A' && studentId.isNotEmpty) ...[
                  AppSpacing.vXs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Student ID:', style: t.bodySmall),
                      Text(studentId, style: t.labelMedium),
                    ],
                  ),
                ],
                AppSpacing.vXs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Period:', style: t.bodySmall),
                    Text(
                      '${widget.period.label} ($rangeLabel)',
                      style: t.labelMedium,
                    ),
                  ],
                ),
                AppSpacing.vXs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Currency:', style: t.bodySmall),
                    Text(
                      Formatters.currentCurrency,
                      style: t.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.vMd,

          // Financial Summary Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  c.surface,
                  AppAccents.blue.color.withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FINANCIAL SUMMARY',
                  style: t.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: c.textSecondary,
                  ),
                ),
                AppSpacing.vMd,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Income', style: t.bodySmall),
                          AppSpacing.vXs,
                          Text(
                            Formatters.money(report.income),
                            style: t.titleMedium?.copyWith(
                              color: AppAccents.green.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Expenses', style: t.bodySmall),
                          AppSpacing.vXs,
                          Text(
                            Formatters.money(report.expense),
                            style: t.titleMedium?.copyWith(
                              color: AppAccents.coral.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.vMd,
                const Divider(),
                AppSpacing.vSm,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Net Savings', style: t.bodySmall),
                          AppSpacing.vXs,
                          Text(
                            '${report.net >= 0 ? '+' : '-'}${Formatters.money(report.net.abs())}',
                            style: t.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: report.net >= 0
                                  ? AppAccents.green.color
                                  : AppAccents.coral.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Savings Rate', style: t.bodySmall),
                          AppSpacing.vXs,
                          Text(
                            report.keptFromIncome == null
                                ? 'N/A'
                                : Formatters.percent(report.keptFromIncome!),
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.vMd,

          // Export & Share Options
          Text(
            'Export & Share Statement',
            style: t.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _isExportingPdf ? 'Exporting PDF...' : 'Export PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  variant: AppButtonVariant.primary,
                  onPressed: _isExportingPdf
                      ? null
                      : () => _exportPdf(
                            report,
                            inRange,
                            rangeLabel,
                            userName,
                            studentId,
                          ),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: AppButton(
                  label: _isExportingCsv ? 'Exporting CSV...' : 'Export CSV',
                  icon: Icons.table_view_rounded,
                  variant: AppButtonVariant.tonal,
                  onPressed: _isExportingCsv
                      ? null
                      : () => _exportCsv(
                            report,
                            inRange,
                            rangeLabel,
                            userName,
                            studentId,
                          ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text('Print / Preview'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                  onPressed: () => _printOrPreviewPdf(
                    report,
                    inRange,
                    rangeLabel,
                    userName,
                    studentId,
                  ),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy CSV'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                  onPressed: () => _copyCsv(
                    report,
                    inRange,
                    rangeLabel,
                    userName,
                    studentId,
                  ),
                ),
              ),
              AppSpacing.hSm,
              IconButton.outlined(
                tooltip: _savedToCloud ? 'Archived to Cloud' : 'Save to Cloud',
                icon: Icon(
                  _savedToCloud
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_upload_outlined,
                  color: _savedToCloud ? AppAccents.green.color : c.primary,
                ),
                onPressed: _savedToCloud || _isSavingToCloud
                    ? null
                    : () => _saveToReportsEntity(report, rangeLabel),
              ),
            ],
          ),
          AppSpacing.vLg,

          // Category Breakdown Section
          Text('Expense Distribution', style: t.titleMedium),
          AppSpacing.vSm,
          if (report.categories.isEmpty)
            Text('No expenses recorded for this period.', style: t.bodySmall)
          else
            AppCard(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.md,
              ),
              child: Column(
                children: [
                  for (final cat in report.categories) ...[
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Row(
                        children: [
                          Icon(cat.category.icon,
                              size: 20, color: c.textPrimary),
                          AppSpacing.hSm,
                          Expanded(
                            child:
                                Text(cat.category.label, style: t.bodyMedium),
                          ),
                          Text(
                            Formatters.money(cat.amount),
                            style: t.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          AppSpacing.hSm,
                          SizedBox(
                            width: 48,
                            child: Text(
                              Formatters.percent(cat.share),
                              textAlign: TextAlign.end,
                              style:
                                  t.bodySmall?.copyWith(color: c.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          AppSpacing.vLg,

          // Itemized Ledger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Itemized Records', style: t.titleMedium),
              Text(
                '${inRange.length} items',
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
          AppSpacing.vSm,
          if (inRange.isEmpty)
            Text('No records found in this range.', style: t.bodySmall)
          else
            AppCard(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xs,
                horizontal: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < inRange.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: (inRange[i].isIncome
                                ? AppAccents.green.color
                                : AppAccents.coral.color)
                            .withOpacity(0.15),
                        child: Icon(
                          inRange[i].isIncome
                              ? Icons.south_west
                              : (inRange[i].category?.icon ?? Icons.north_east),
                          size: 16,
                          color: inRange[i].isIncome
                              ? AppAccents.green.color
                              : AppAccents.coral.color,
                        ),
                      ),
                      title: Text(
                        inRange[i].description.isEmpty
                            ? (inRange[i].category?.label ?? 'Transaction')
                            : inRange[i].description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${DateFormat('d MMM yyyy').format(inRange[i].date)} • ${(inRange[i].paymentMode?.name ?? 'cash').toUpperCase()}',
                        style: t.bodySmall?.copyWith(fontSize: 11),
                      ),
                      trailing: Text(
                        '${inRange[i].isIncome ? '+' : '-'}${Formatters.money(inRange[i].amount)}',
                        style: t.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: inRange[i].isIncome
                              ? AppAccents.green.color
                              : AppAccents.coral.color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          AppSpacing.vXl,
        ],
      ),
    );
  }
}
