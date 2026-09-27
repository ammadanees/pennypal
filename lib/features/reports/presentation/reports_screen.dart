import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_categories.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/report_strings.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_chart_colors.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_durations.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/adaptive_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/budget_progress.dart';
import '../../../shared/widgets/charts/donut_chart.dart';
import '../../../shared/widgets/charts/monthly_bar_chart.dart';
import '../../../shared/widgets/money_display.dart';
import '../../../shared/widgets/savings_progress.dart';
import '../../budgets/data/budget_repository.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../dashboard/domain/finance_calculator.dart';
import '../../savings/data/savings_repository.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../domain/report_calculator.dart';
import 'statement_preview_sheet.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final all = transactionsAsync.asData?.value ?? const [];

    return AppScaffold(
      title: ReportStrings.title,
      actions: [
        if (all.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Statement',
            onPressed: () => StatementPreviewSheet.show(
              context,
              allTransactions: all,
              period: _period,
            ),
          ),
      ],
      body: AsyncValueView<List<FinanceTransaction>>(
        value: transactionsAsync,
        onRetry: () => ref.invalidate(transactionsProvider),
        data: (all) {
          if (all.isEmpty) {
            return const AppEmptyState(
              icon: Icons.insights_outlined,
              title: ReportStrings.emptyAllTitle,
              message: ReportStrings.emptyAllMessage,
            );
          }
          return _ReportsBody(
            all: all,
            period: _period,
            onPeriod: (p) => setState(() => _period = p),
          );
        },
      ),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody({
    required this.all,
    required this.period,
    required this.onPeriod,
  });

  final List<FinanceTransaction> all;
  final ReportPeriod period;
  final ValueChanged<ReportPeriod> onPeriod;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final range = period.range(now);
    final report = ReportCalculator.forRange(all, range);
    final days = ReportCalculator.daysCovered(range, now);
    final rangeLabel =
        '${DateFormat('d MMM').format(range.start)} - ${DateFormat('d MMM y').format(range.end)}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 800 ? 2 : 1;
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final p in ReportPeriod.values) ...[
                    AppChip(
                      label: p.label,
                      selected: p == period,
                      onSelected: () => onPeriod(p),
                    ),
                    AppSpacing.hSm,
                  ],
                ],
              ),
            ),
            AppSpacing.vSm,
            Text(rangeLabel, style: context.text.bodySmall),
            AppSpacing.vMd,
            _StatsGrid(report: report, days: days),
            AppSpacing.vMd,
            AdaptiveGrid(
              columns: columns,
              children: [
                _ReportCard(
                  title: ReportStrings.incomeVsExpenseTitle,
                  child: _IncomeVsExpense(report: report),
                ),
                _ReportCard(
                  title: ReportStrings.categoryTitle,
                  child: _CategoryBreakdown(report: report),
                ),
                _ReportCard(
                  title: ReportStrings.monthlyTitle,
                  subtitle: ReportStrings.monthlySubtitle,
                  child: _MonthlySpending(all: all, now: now),
                ),
                _ReportCard(
                  title: ReportStrings.budgetTitle,
                  subtitle: AppDates.monthLabel(period.budgetMonth(now)),
                  child: _BudgetUsage(all: all, month: period.budgetMonth(now)),
                ),
                _ReportCard(
                  title: ReportStrings.savingsTitle,
                  child: const _SavingsSummary(),
                ),
                _ReportCard(
                  title: 'Payment Methods & Accounts',
                  subtitle: 'Cash, Card, and Bank income vs expense',
                  child: _PaymentModesBreakdown(report: report),
                ),
              ],
            ),
            AppSpacing.vMd,
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppAccents.blue.color.withOpacity(0.12),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: AppAccents.blue.color,
                      size: 28,
                    ),
                  ),
                  AppSpacing.hMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Official Student Statement',
                          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Export CSV & archive report for ${period.label}',
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hSm,
                  AppButton(
                    label: 'Export',
                    variant: AppButtonVariant.tonal,
                    expand: false,
                    onPressed: () => StatementPreviewSheet.show(
                      context,
                      allTransactions: all,
                      period: period,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.bottomNavClearance),
          ],
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.report, required this.days});

  final PeriodReport report;
  final int days;

  @override
  Widget build(BuildContext context) {
    final kept = report.keptFromIncome;
    final top = report.topCategory;

    return AdaptiveGrid(
      columns: 2,
      spacing: AppSpacing.sm,
      children: [
        _Stat(
          label: ReportStrings.statIncome,
          child: MoneyDisplay(amount: report.income, kind: MoneyKind.income),
        ),
        _Stat(
          label: ReportStrings.statExpenses,
          child: MoneyDisplay(amount: report.expense, kind: MoneyKind.expense),
        ),
        _Stat(
          label: ReportStrings.statNet,
          child: MoneyDisplay(amount: report.net),
        ),
        _Stat(
          label: ReportStrings.statSavingsRate,
          text: kept == null ? ReportStrings.notAvailable : Formatters.percent(kept),
        ),
        _Stat(
          label: ReportStrings.statDailyAverage,
          child: MoneyDisplay(amount: report.expense / days, size: MoneySize.body),
        ),
        _Stat(
          label: ReportStrings.statTopCategory,
          text: top == null ? ReportStrings.notAvailable : top.category.label,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, this.child, this.text});

  final String label;
  final Widget? child;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.bodySmall),
          AppSpacing.vXs,
          child ??
              Text(
                text ?? '',
                style: context.text.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: context.text.titleMedium),
          ),
          if (subtitle != null) Text(subtitle!, style: context.text.bodySmall),
          AppSpacing.vMd,
          child,
        ],
      ),
    );
  }
}

class _ChartEmpty extends StatelessWidget {
  const _ChartEmpty(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.bar_chart_outlined, color: c.textMuted),
          AppSpacing.hSm,
          Expanded(child: Text(message, style: context.text.bodyMedium)),
        ],
      ),
    );
  }
}

class _IncomeVsExpense extends StatelessWidget {
  const _IncomeVsExpense({required this.report});

  final PeriodReport report;

  @override
  Widget build(BuildContext context) {
    if (report.transactionCount == 0) {
      return const _ChartEmpty(ReportStrings.emptyPeriod);
    }
    final c = context.colors;
    final maxValue = report.income > report.expense ? report.income : report.expense;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ValueBar(
          label: ReportStrings.statIncome,
          icon: Icons.south_west,
          amount: report.income,
          max: maxValue,
          color: c.income,
          kind: MoneyKind.income,
        ),
        AppSpacing.vMd,
        _ValueBar(
          label: ReportStrings.statExpenses,
          icon: Icons.north_east,
          amount: report.expense,
          max: maxValue,
          color: c.expense,
          kind: MoneyKind.expense,
        ),
        AppSpacing.vMd,
        Text(
          ReportStrings.netSummary(
            '${report.net < 0 ? '-' : '+'}${Formatters.money(report.net.abs())}',
          ),
          style: context.text.labelLarge,
        ),
      ],
    );
  }
}

class _ValueBar extends StatelessWidget {
  const _ValueBar({
    required this.label,
    required this.icon,
    required this.amount,
    required this.max,
    required this.color,
    required this.kind,
  });

  final String label;
  final IconData icon;
  final double amount;
  final double max;
  final Color color;
  final MoneyKind kind;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fraction = max <= 0 ? 0.0 : (amount / max).clamp(0.0, 1.0);
    return Semantics(
      label: '$label ${Formatters.money(amount)}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: color),
              AppSpacing.hXs,
              Expanded(child: Text(label, style: context.text.labelLarge)),
              MoneyDisplay(amount: amount, size: MoneySize.body, kind: kind),
            ],
          ),
          AppSpacing.vXs,
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: AppDurations.slow,
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: AppDimensions.progressHeight,
                color: color,
                backgroundColor: c.border,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.report});

  final PeriodReport report;

  @override
  Widget build(BuildContext context) {
    if (report.categories.isEmpty) {
      return const _ChartEmpty(ReportStrings.emptySpending);
    }
    final t = context.text;
    final segments = [
      for (final share in report.categories)
        DonutSegment(share.amount, AppChartColors.forCategory(context, share.category)),
    ];
    final summary = report.categories
        .map((s) => '${s.category.label} ${Formatters.percent(s.share)}')
        .join(', ');

    return Column(
      children: [
        Center(
          child: DonutChart(
            segments: segments,
            semanticLabel: 'Spending by category: $summary',
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(Formatters.compact(report.expense), style: t.titleLarge),
                Text(ReportStrings.spent, style: t.bodySmall),
              ],
            ),
          ),
        ),
        AppSpacing.vMd,
        for (final share in report.categories)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Container(
                  width: AppSpacing.md,
                  height: AppSpacing.md,
                  decoration: BoxDecoration(
                    color: AppChartColors.forCategory(context, share.category),
                    borderRadius: AppRadius.smAll,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(child: Text(share.category.label, style: t.bodyMedium)),
                Text(Formatters.money(share.amount), style: t.labelLarge),
                AppSpacing.hSm,
                SizedBox(
                  width: 44,
                  child: Text(
                    Formatters.percent(share.share),
                    textAlign: TextAlign.end,
                    style: t.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MonthlySpending extends StatelessWidget {
  const _MonthlySpending({required this.all, required this.now});

  final List<FinanceTransaction> all;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final totals = ReportCalculator.monthlyTotals(all, now);
    if (totals.every((m) => m.expense <= 0)) {
      return const _ChartEmpty(ReportStrings.emptySpending);
    }
    final currentMonth = AppDates.startOfMonth(now);
    final summary = totals
        .map((m) => '${DateFormat('MMMM').format(m.month)} ${Formatters.money(m.expense)}')
        .join(', ');
    return MonthlyBarChart(
      color: context.colors.expense,
      semanticLabel: 'Monthly spending: $summary',
      bars: [
        for (final m in totals)
          MonthBar(
            label: DateFormat('MMM').format(m.month),
            value: m.expense,
            highlighted: m.month == currentMonth,
          ),
      ],
    );
  }
}

class _BudgetUsage extends ConsumerWidget {
  const _BudgetUsage({required this.all, required this.month});

  final List<FinanceTransaction> all;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(budgetsProvider).when(
          loading: () => const AppLoading(rows: 2),
          error: (_, __) => const _ChartEmpty(ReportStrings.noBudget),
          data: (budgets) {
            final budget = budgets.forMonth(month);
            if (budget == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ChartEmpty(ReportStrings.noBudget),
                  AppButton(
                    label: AppStrings.createBudget,
                    variant: AppButtonVariant.tonal,
                    expand: false,
                    onPressed: () =>
                        context.push(AppRoutes.budgetEdit, extra: month),
                  ),
                ],
              );
            }
            final status = BudgetCalculator.status(
              budget,
              FinanceCalculator.monthSummary(all, month),
            );
            return Column(
              children: [
                BudgetProgress(
                  label: ReportStrings.budgetFor(AppDates.monthLabel(month)),
                  spent: status.spent,
                  limit: status.total,
                  alertThreshold: status.alertThreshold,
                ),
                for (final usage in status.categories)
                  if (usage.limit != null) ...[
                    AppSpacing.vMd,
                    BudgetProgress(
                      label: usage.category.label,
                      spent: usage.spent,
                      limit: usage.limit!,
                      alertThreshold: status.alertThreshold,
                    ),
                  ],
              ],
            );
          },
        );
  }
}

class _SavingsSummary extends ConsumerWidget {
  const _SavingsSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(savingsGoalsProvider).when(
          loading: () => const AppLoading(rows: 2),
          error: (_, __) => const _ChartEmpty(ReportStrings.noGoals),
          data: (goals) {
            final active = goals.where((g) => !g.isCompleted).toList();
            final completed = goals.where((g) => g.isCompleted).length;
            if (active.isEmpty && completed == 0) {
              return const _ChartEmpty(ReportStrings.noGoals);
            }
            final saved = active.fold<double>(0, (sum, g) => sum + g.currentAmount);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (active.isNotEmpty)
                  Text(
                    ReportStrings.savedAcross(Formatters.money(saved), active.length),
                    style: context.text.labelLarge,
                  ),
                if (completed > 0)
                  Text(
                    ReportStrings.completedGoals(completed),
                    style: context.text.bodySmall,
                  ),
                for (final goal in active) ...[
                  AppSpacing.vMd,
                  SavingsProgress(
                    label: goal.name,
                    current: goal.currentAmount,
                    target: goal.targetAmount,
                  ),
                ],
              ],
            );
          },
        );
  }
}

class _PaymentModesBreakdown extends StatelessWidget {
  const _PaymentModesBreakdown({required this.report});

  final PeriodReport report;

  @override
  Widget build(BuildContext context) {
    final modes = report.paymentModes;
    final hasAnyActivity = modes.any((m) => m.hasActivity);

    if (!hasAnyActivity) {
      return const _ChartEmpty('No payment method activity in this period.');
    }

    return Column(
      children: [
        for (var i = 0; i < modes.length; i++) ...[
          if (i > 0) const Divider(height: 20),
          _PaymentModeRow(item: modes[i]),
        ],
      ],
    );
  }
}

class _PaymentModeRow extends StatelessWidget {
  const _PaymentModeRow({required this.item});

  final PaymentModeShare item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    final accent = switch (item.mode) {
      PaymentMode.cash => AppAccents.green,
      PaymentMode.card => AppAccents.purple,
      PaymentMode.bankTransfer => AppAccents.blue,
      PaymentMode.wallet => AppAccents.amber,
    };

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.color.withOpacity(0.12),
            borderRadius: AppRadius.smAll,
          ),
          child: Icon(item.mode.icon, color: accent.color, size: 20),
        ),
        AppSpacing.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.mode.label,
                style: t.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Text(
                    'In: +${Formatters.money(item.income)}',
                    style: t.bodySmall?.copyWith(
                      color: AppAccents.green.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Out: -${Formatters.money(item.expense)}',
                    style: t.bodySmall?.copyWith(
                      color: AppAccents.coral.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Sum',
              style: t.bodySmall?.copyWith(fontSize: 10, color: c.textMuted),
            ),
            Text(
              Formatters.money(item.net),
              style: t.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: item.net >= 0 ? c.textPrimary : AppAccents.coral.color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
