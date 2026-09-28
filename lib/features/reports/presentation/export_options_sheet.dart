import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/data/auth_providers.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../domain/report_calculator.dart';
import '../domain/report_export_service.dart';
import 'statement_preview_sheet.dart';

class ExportOptionsSheet extends ConsumerStatefulWidget {
  const ExportOptionsSheet({
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
      builder: (_) => ExportOptionsSheet(
        allTransactions: allTransactions,
        period: period,
      ),
    );

  }

  @override
  ConsumerState<ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends ConsumerState<ExportOptionsSheet> {
  bool _isExporting = false;
  String? _exportingLabel;

  Future<void> _handlePdfExport({required bool printPreview}) async {
    setState(() {
      _isExporting = true;
      _exportingLabel = printPreview ? 'Preparing PDF preview...' : 'Generating PDF statement...';
    });

    try {
      final now = DateTime.now();
      final range = widget.period.range(now);
      final report = ReportCalculator.forRange(widget.allTransactions, range);
      final inRange = widget.allTransactions
          .where((tr) => range.contains(tr.date))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final user = ref.read(authStateProvider).asData?.value;
      final userName = user?.fullName ?? 'Student';
      final studentId = user?.studentId ?? 'N/A';
      final rangeLabel =
          '${DateFormat('d MMM yyyy').format(range.start)} - ${DateFormat('d MMM yyyy').format(range.end)}';

      if (printPreview) {
        await ReportExportService.printOrPreviewPdf(
          report: report,
          inRange: inRange,
          rangeLabel: rangeLabel,
          periodName: widget.period.label,
          userName: userName,
          studentId: studentId,
        );
      } else {
        await ReportExportService.exportPdf(
          report: report,
          inRange: inRange,
          rangeLabel: rangeLabel,
          periodName: widget.period.label,
          userName: userName,
          studentId: studentId,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  printPreview
                      ? 'PDF preview launched!'
                      : 'PDF statement exported successfully!',
                ),
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
          content: Text('Export failed: $e'),
          backgroundColor: AppAccents.coral.color,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportingLabel = null;
        });
      }
    }
  }

  Future<void> _handleCsvExport() async {
    setState(() {
      _isExporting = true;
      _exportingLabel = 'Exporting CSV spreadsheet...';
    });

    try {
      final now = DateTime.now();
      final range = widget.period.range(now);
      final report = ReportCalculator.forRange(widget.allTransactions, range);
      final inRange = widget.allTransactions
          .where((tr) => range.contains(tr.date))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final user = ref.read(authStateProvider).asData?.value;
      final userName = user?.fullName ?? 'Student';
      final studentId = user?.studentId ?? 'N/A';
      final rangeLabel =
          '${DateFormat('d MMM yyyy').format(range.start)} - ${DateFormat('d MMM yyyy').format(range.end)}';

      await ReportExportService.exportCsvFile(
        report: report,
        inRange: inRange,
        rangeLabel: rangeLabel,
        periodName: widget.period.label,
        userName: userName,
        studentId: studentId,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.table_view_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('CSV statement exported successfully!')),
            ],
          ),
          backgroundColor: AppAccents.green.color,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppAccents.coral.color,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportingLabel = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Icons.file_download_outlined,
                    color: c.primary,
                    size: 24,
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Statement',
                        style:
                            t.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Choose format for ${widget.period.label}',
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.vMd,
          if (_isExporting) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    AppSpacing.vMd,
                    Text(
                      _exportingLabel ?? 'Processing...',
                      style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            _ExportOptionTile(
              icon: Icons.picture_as_pdf_rounded,
              iconColor: AppAccents.coral.color,
              iconBg: AppAccents.coral.color.withOpacity(0.12),
              title: 'Export as PDF',
              subtitle: 'Formatted document with summary, charts & transaction ledger',
              badge: 'Recommended',
              onTap: () => _handlePdfExport(printPreview: false),
            ),
            AppSpacing.vSm,
            _ExportOptionTile(
              icon: Icons.table_view_rounded,
              iconColor: AppAccents.green.color,
              iconBg: AppAccents.green.color.withOpacity(0.12),
              title: 'Export as CSV (Excel / Sheets)',
              subtitle: 'Raw spreadsheet data ready for Excel and Google Sheets',
              onTap: _handleCsvExport,
            ),
            AppSpacing.vSm,
            _ExportOptionTile(
              icon: Icons.print_rounded,
              iconColor: AppAccents.blue.color,
              iconBg: AppAccents.blue.color.withOpacity(0.12),
              title: 'Print / Save PDF via System',
              subtitle: 'Open native device print dialog or save to PDF',
              onTap: () => _handlePdfExport(printPreview: true),
            ),
            AppSpacing.vSm,
            _ExportOptionTile(
              icon: Icons.receipt_long_rounded,
              iconColor: c.primary,
              iconBg: c.primarySoft,
              title: 'View In-App Statement & Cloud Archive',
              subtitle: 'Preview full itemized ledger and save to Cloud Reports',
              onTap: () {
                Navigator.of(context).pop();
                StatementPreviewSheet.show(
                  context,
                  allTransactions: widget.allTransactions,
                  period: widget.period,
                );
              },
            ),
          ],
        ],
      ),
    ),
  );
}
}

class _ExportOptionTile extends StatelessWidget {
  const _ExportOptionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: t.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (badge != null) ...[
                          AppSpacing.hXs,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppAccents.green.color.withOpacity(0.12),
                              borderRadius: AppRadius.pillAll,
                            ),
                            child: Text(
                              badge!,
                              style: t.bodySmall?.copyWith(
                                fontSize: 10,
                                color: AppAccents.green.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.vXs,
                    Text(
                      subtitle,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
