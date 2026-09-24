import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/finance_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_inline_message.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/budget_progress.dart';
import '../../../shared/widgets/money_display.dart';
import '../../../shared/widgets/savings_progress.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/data/auth_providers.dart';
import '../../budgets/data/budget_repository.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../savings/data/savings_repository.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../../transactions/presentation/transaction_detail_sheet.dart';
import '../../transactions/presentation/transaction_display.dart';
import '../data/sync_status.dart';
import '../domain/finance_calculator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(authStateProvider).valueOrNull?.firstName;
    return AppScaffold(
      body: AsyncValueView<List<FinanceTransaction>>(
        value: ref.watch(transactionsProvider),
        onRetry: () => ref.invalidate(transactionsProvider),
        data: (all) => _HomeContent(all: all, name: name),
      ),
    );
  }
}

String _greeting(DateTime now) {
  if (now.hour < 12) return FinanceStrings.greetingMorning;
  if (now.hour < 17) return FinanceStrings.greetingAfternoon;
  return FinanceStrings.greetingEvening;
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.all, this.name});

  final List<FinanceTransaction> all;
  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingWriteCountProvider);
    final now = DateTime.now();
    final summary = FinanceCalculator.monthSummary(all, now);

    final header = <Widget>[
      Text('${_greeting(now)}, ${name ?? 'there'}',
          style: context.text.headlineMedium),
      if (pending > 0) ...[
        AppSpacing.vMd,
        AppInlineMessage(
          message: FinanceStrings.pendingChanges(pending),
          kind: InlineMessageKind.info,
        ),
      ],
      AppSpacing.vLg,
    ];

    final overview = all.isEmpty
        ? AppCard(
            child: AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: AppStrings.emptyTransactionsTitle,
              message: AppStrings.emptyTransactionsMessage,
              actionLabel: AppStrings.addExpense,
              onAction: () => context.push(
                AppRoutes.transactionNew,
                extra: TransactionType.expense,
              ),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BalanceCard(balance: FinanceCalculator.balance(all)),
              AppSpacing.vMd,
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.south_west,
                      label: FinanceStrings.income,
                      amount: summary.income,
                      kind: MoneyKind.income,
                    ),
                  ),
                  AppSpacing.hMd,
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.north_east,
                      label: FinanceStrings.expenses,
                      amount: summary.expense,
                      kind: MoneyKind.expense,
                    ),
                  ),
                ],
              ),
            ],
          );

    const actions = _QuickActions();
    const budget = _BudgetSection();
    const goals = _GoalSection();
    final recent = all.isEmpty ? null : _RecentSection(items: all.take(5).toList());

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        final body = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [overview, AppSpacing.vLg, actions],
                    ),
                  ),
                  AppSpacing.hLg,
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [budget, goals, if (recent != null) recent],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  overview,
                  AppSpacing.vLg,
                  actions,
                  budget,
                  goals,
                  if (recent != null) recent,
                ],
              );
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          children: [...header, body],
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      color: c.primary,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FinanceStrings.availableBalance,
            style: context.text.labelLarge
                ?.copyWith(color: c.onPrimary.withOpacity(0.8)),
          ),
          AppSpacing.vSm,
          MoneyDisplay(amount: balance, size: MoneySize.hero, color: c.onPrimary),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.amount,
    required this.kind,
  });

  final IconData icon;
  final String label;
  final double amount;
  final MoneyKind kind;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = kind == MoneyKind.income ? c.income : c.expense;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: tint),
              AppSpacing.hXs,
              Text(label, style: context.text.labelLarge),
            ],
          ),
          Text(FinanceStrings.thisMonth, style: context.text.bodySmall),
          AppSpacing.vSm,
          MoneyDisplay(amount: amount, kind: kind),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.south_west,
            label: FinanceStrings.quickAddIncome,
            onTap: () => context.push(AppRoutes.transactionNew,
                extra: TransactionType.income),
          ),
        ),
        Expanded(
          child: _QuickAction(
            icon: Icons.north_east,
            label: FinanceStrings.quickAddExpense,
            onTap: () => context.push(AppRoutes.transactionNew,
                extra: TransactionType.expense),
          ),
        ),
        Expanded(
          child: _QuickAction(
            icon: Icons.pie_chart_outline,
            label: FinanceStrings.quickBudget,
            onTap: () => context.go(AppRoutes.budget),
          ),
        ),
        Expanded(
          child: _QuickAction(
            icon: Icons.savings_outlined,
            label: FinanceStrings.quickSavings,
            onTap: () => context.go(AppRoutes.savings),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppDimensions.touchTarget,
                height: AppDimensions.touchTarget,
                decoration:
                    BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
                child: Icon(icon, size: AppDimensions.iconMd, color: c.primary),
              ),
              AppSpacing.vXs,
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: context.text.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetSection extends ConsumerWidget {
  const _BudgetSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = AppDates.startOfMonth(DateTime.now());
    final transactions = ref.watch(transactionsProvider).valueOrNull ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: FinanceStrings.sectionBudget,
          actionLabel: FinanceStrings.details,
          onAction: () => context.go(AppRoutes.budget),
        ),
        ref.watch(budgetsProvider).when(
              loading: () => const SkeletonBox(height: 96),
              error: (_, __) => const SizedBox.shrink(),
              data: (budgets) {
                final budget = budgets.forMonth(month);
                if (budget == null) {
                  return _CtaCard(
                    icon: Icons.pie_chart_outline,
                    title: AppStrings.emptyBudgetTitle,
                    message: AppStrings.emptyBudgetMessage,
                    actionLabel: AppStrings.createBudget,
                    onAction: () => context.push(
                      AppRoutes.budgetEdit,
                      extra: month,
                    ),
                  );
                }
                final status = BudgetCalculator.status(
                  budget,
                  FinanceCalculator.monthSummary(transactions, month),
                );
                return AppCard(
                  onTap: () => context.go(AppRoutes.budget),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BudgetProgress(
                        label: FinanceStrings.overall,
                        spent: status.spent,
                        limit: status.total,
                        alertThreshold: status.alertThreshold,
                      ),
                      AppSpacing.vSm,
                      Text(
                        status.remaining >= 0
                            ? '${Formatters.money(status.remaining)} left'
                            : '${Formatters.money(status.overBy)} over',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
      ],
    );
  }
}

class _GoalSection extends ConsumerWidget {
  const _GoalSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: FinanceStrings.sectionSavings,
          actionLabel: FinanceStrings.seeAll,
          onAction: () => context.go(AppRoutes.savings),
        ),
        ref.watch(savingsGoalsProvider).when(
              loading: () => const SkeletonBox(height: 96),
              error: (_, __) => const SizedBox.shrink(),
              data: (goals) {
                final active = goals.where((g) => !g.isCompleted).toList()
                  ..sort((a, b) => (b.currentAmount / (b.targetAmount <= 0 ? 1 : b.targetAmount))
                      .compareTo(a.currentAmount / (a.targetAmount <= 0 ? 1 : a.targetAmount)));
                if (active.isEmpty) {
                  return _CtaCard(
                    icon: Icons.savings_outlined,
                    title: AppStrings.emptyGoalsTitle,
                    message: AppStrings.emptyGoalsMessage,
                    actionLabel: AppStrings.createGoal,
                    onAction: () => context.push(AppRoutes.goalEdit),
                  );
                }
                final goal = active.first;
                return AppCard(
                  onTap: () => context.go(AppRoutes.savings),
                  child: SavingsProgress(
                    label: goal.name,
                    current: goal.currentAmount,
                    target: goal.targetAmount,
                  ),
                );
              },
            ),
      ],
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({required this.items});

  final List<FinanceTransaction> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: FinanceStrings.sectionRecent,
          actionLabel: FinanceStrings.seeAll,
          onAction: () => context.go(AppRoutes.activity),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(),
                TransactionListTile(
                  transaction: items[i],
                  onTap: () => showTransactionDetail(context, items[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact call-to-action shown when a section has no data yet.
class _CtaCard extends StatelessWidget {
  const _CtaCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: c.primary),
              AppSpacing.hSm,
              Expanded(child: Text(title, style: context.text.titleMedium)),
            ],
          ),
          AppSpacing.vXs,
          Text(message, style: context.text.bodySmall),
          AppSpacing.vMd,
          AppButton(
            label: actionLabel,
            variant: AppButtonVariant.tonal,
            expand: false,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
