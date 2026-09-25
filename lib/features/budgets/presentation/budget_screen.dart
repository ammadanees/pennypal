import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/finance_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_inline_message.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/budget_progress.dart';
import '../../../shared/widgets/category_card.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/section_header.dart';
import '../../dashboard/domain/finance_calculator.dart';
import '../../transactions/data/transaction_repository.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';
import '../domain/budget_calculator.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Budget budget) async {
    final ok = await confirmAction(
      context,
      title: FinanceStrings.budgetDeleteTitle,
      message: FinanceStrings.budgetDeleteMessage,
      confirmLabel: FinanceStrings.delete,
    );
    if (!ok || !context.mounted) return;
    await ref.read(budgetRepositoryProvider).delete(budget);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(FinanceStrings.budgetDeleted)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedBudgetMonthProvider);
    final budgets = ref.watch(budgetsProvider);
    final transactions = ref.watch(transactionsProvider).valueOrNull ?? const [];
    final current = budgets.valueOrNull?.forMonth(month);

    return AppScaffold(
      title: FinanceStrings.budgetTitle,
      actions: [
        if (current != null) ...[
          IconButton(
            tooltip: FinanceStrings.budgetFormEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.budgetEdit, extra: current),
          ),
          IconButton(
            tooltip: FinanceStrings.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref, current),
          ),
        ],
      ],
      body: Column(
        children: [
          _MonthSwitcher(month: month),
          Expanded(
            child: AsyncValueView<List<Budget>>(
              value: budgets,
              onRetry: () => ref.invalidate(budgetsProvider),
              data: (list) {
                final budget = list.forMonth(month);
                if (budget == null) {
                  return AppEmptyState(
                    icon: Icons.pie_chart_outline,
                    title: month == AppDates.startOfMonth(DateTime.now())
                        ? AppStrings.emptyBudgetTitle
                        : FinanceStrings.noBudgetFor(AppDates.monthLabel(month)),
                    message: AppStrings.emptyBudgetMessage,
                    actionLabel: AppStrings.createBudget,
                    onAction: () =>
                        context.push(AppRoutes.budgetEdit, extra: month),
                  );
                }
                final status = BudgetCalculator.status(
                  budget,
                  FinanceCalculator.monthSummary(transactions, month),
                );
                return _BudgetContent(status: status);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSwitcher extends ConsumerWidget {
  const _MonthSwitcher({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void shift(int by) => ref.read(selectedBudgetMonthProvider.notifier).state =
        AppDates.addMonths(month, by);
    return Row(
      children: [
        IconButton(
          tooltip: FinanceStrings.previousMonth,
          icon: const Icon(Icons.chevron_left),
          onPressed: () => shift(-1),
        ),
        Expanded(
          child: Center(
            child: Text(AppDates.monthLabel(month),
                style: context.text.titleMedium),
          ),
        ),
        IconButton(
          tooltip: FinanceStrings.nextMonth,
          icon: const Icon(Icons.chevron_right),
          onPressed: () => shift(1),
        ),
      ],
    );
  }
}

class _BudgetContent extends StatelessWidget {
  const _BudgetContent({required this.status});

  final BudgetStatus status;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xl,
      ),
      children: [
        _OverviewCard(status: status),
        if (status.level == BudgetLevel.over) ...[
          AppSpacing.vMd,
          AppInlineMessage(
            message: FinanceStrings.overBudgetMessage(
              Formatters.money(status.overBy),
            ),
          ),
        ] else if (status.level == BudgetLevel.nearing) ...[
          AppSpacing.vMd,
          AppInlineMessage(
            message: FinanceStrings.nearingBudgetMessage(
              Formatters.percent(status.ratio),
            ),
            kind: InlineMessageKind.info,
          ),
        ],
        const SectionHeader(title: FinanceStrings.budgetByCategory),
        if (status.categories.isEmpty)
          Text(AppStrings.emptyBudgetMessage, style: context.text.bodySmall)
        else
          for (final usage in status.categories)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CategoryCard(
                category: usage.category,
                spent: usage.spent,
                shareOfSpend: status.spent <= 0 ? 0 : usage.spent / status.spent,
                limit: usage.limit,
                alertThreshold: status.alertThreshold,
              ),
            ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.status});

  final BudgetStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final color = switch (status.level) {
      BudgetLevel.onTrack => c.success,
      BudgetLevel.nearing => c.warning,
      BudgetLevel.over => c.error,
    };
    final over = status.remaining < 0;

    Widget stat(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: t.bodySmall),
              Text(value, style: t.titleMedium),
            ],
          ),
        );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProgressRing(
                value: status.ratio,
                color: color,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(Formatters.percent(status.ratio), style: t.titleLarge),
                    Text(FinanceStrings.used, style: t.bodySmall),
                  ],
                ),
              ),
              AppSpacing.hLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    stat(FinanceStrings.budgetTotal,
                        Formatters.money(status.total)),
                    stat(FinanceStrings.budgetSpent,
                        Formatters.money(status.spent)),
                    stat(
                      over
                          ? FinanceStrings.budgetOverBy
                          : FinanceStrings.budgetRemaining,
                      Formatters.money(over ? status.overBy : status.remaining),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Icon(Icons.notifications_none,
                  size: AppDimensions.iconSm, color: c.textSecondary),
              AppSpacing.hXs,
              Text(
                '${FinanceStrings.alertAt} ${Formatters.percent(status.alertThreshold)}',
                style: t.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
