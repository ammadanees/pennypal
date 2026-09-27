import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/finance_strings.dart';
import '../../../core/constants/step5_strings.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/accent_icon_box.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_inline_message.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/budget_progress.dart';
import '../../../shared/widgets/color_segment_bar.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/insight_banner.dart';
import '../../../shared/widgets/money_display.dart';
import '../../../shared/widgets/round_action.dart';
import '../../../shared/widgets/savings_progress.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../budgets/data/budget_repository.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../insights/domain/insight_calculator.dart';
import '../../../core/constants/app_categories.dart';
import '../../notifications/data/notification_repository.dart';
import '../../savings/data/savings_repository.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../../transactions/presentation/split_bill_sheet.dart';
import '../../transactions/presentation/transaction_detail_sheet.dart';
import '../../transactions/presentation/transaction_display.dart';
import '../../transactions/presentation/transaction_filter_controller.dart';
import '../data/sync_status.dart';
import '../domain/finance_calculator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    return AppScaffold(
      body: AsyncValueView<List<FinanceTransaction>>(
        value: ref.watch(transactionsProvider),
        onRetry: () => ref.invalidate(transactionsProvider),
        data: (all) => _HomeContent(all: all, user: user),
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
  const _HomeContent({required this.all, this.user});

  final List<FinanceTransaction> all;
  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingWriteCountProvider);
    final now = DateTime.now();
    final summary = FinanceCalculator.monthSummary(all, now);
    final budget =
        ref.watch(budgetsProvider).valueOrNull?.forMonth(AppDates.startOfMonth(now));
    final insights = InsightCalculator.forMonth(all, budget: budget, now: now)
        .take(2)
        .toList();

    final header = <Widget>[
      _HomeHeader(user: user, greeting: _greeting(now)),
      if (pending > 0) ...[
        AppSpacing.vMd,
        AppInlineMessage(
          message: FinanceStrings.pendingChanges(pending),
          kind: InlineMessageKind.info,
        ),
      ],
      AppSpacing.vLg,
    ];

    final hero = all.isEmpty
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
        : _BalanceHero(balance: FinanceCalculator.balance(all), net: summary.net, now: now);

    final summaryRow = all.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.south_west,
                    accent: AppAccents.green,
                    label: FinanceStrings.income,
                    amount: summary.income,
                    kind: MoneyKind.income,
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.north_east,
                    accent: AppAccents.coral,
                    label: FinanceStrings.expenses,
                    amount: summary.expense,
                    kind: MoneyKind.expense,
                  ),
                ),
              ],
            ),
          );

    final insightWidgets = Column(
      children: [
        for (final insight in insights)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: InsightBanner(
              message: insight.message,
              accent: switch (insight.kind) {
                InsightKind.good => AppAccents.green,
                InsightKind.watch => AppAccents.coral,
                InsightKind.info => AppAccents.blue,
              },
              icon: switch (insight.kind) {
                InsightKind.good => Icons.thumb_up_alt_outlined,
                InsightKind.watch => Icons.trending_up,
                InsightKind.info => Icons.lightbulb_outline,
              },
              onTap: () => context.push(AppRoutes.assistant),
            ),
          ),
      ],
    );

    final ribbon = summary.expense > 0 ? _SpendingRibbon(summary: summary) : const SizedBox.shrink();
    final accountsSection = all.isEmpty
        ? const SizedBox.shrink()
        : _AccountsBreakdownSection(all: all, now: now);
    const budgetSection = _BudgetSection();
    const goals = _GoalSection();
    final recent = all.isEmpty ? null : _RecentSection(items: all.take(5).toList());

    const quickShortcuts = _QuickShortcutsSection();

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
                      children: [
                        hero,
                        summaryRow,
                        accountsSection,
                        quickShortcuts,
                        insightWidgets,
                        ribbon,
                      ],
                    ),
                  ),
                  AppSpacing.hLg,
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [budgetSection, goals, if (recent != null) recent],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hero,
                  summaryRow,
                  accountsSection,
                  quickShortcuts,
                  insightWidgets,
                  budgetSection,
                  ribbon,
                  goals,
                  if (recent != null) recent,
                ],
              );
        return ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppDimensions.bottomNavClearance,
          ),
          children: [...header, body, AppSpacing.vLg],
        );
      },
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.user, required this.greeting});

  final AppUser? user;
  final String greeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.text;
    final unread = ref.watch(unreadNotificationCountProvider);
    final currentUser = ref.watch(authStateProvider).valueOrNull ?? user;
    return Row(
      children: [
        UserAvatar(
          photoUrl: currentUser?.photoUrl,
          initials: currentUser?.initials ?? '?',
          size: 48,
          tooltip: AppStrings.profileTitle,
          onTap: () => context.push(AppRoutes.profile),
        ),
        AppSpacing.hMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: t.bodySmall),
              Text(currentUser?.firstName ?? 'there',
                  style: t.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        _HeaderButton(
          icon: Icons.auto_awesome,
          tooltip: Step5Strings.assistantTitle,
          onTap: () => context.push(AppRoutes.assistant),
        ),
        AppSpacing.hSm,
        _HeaderButton(
          icon: Icons.notifications_none,
          tooltip: Step5Strings.notificationsTitle,
          showBadge: unread > 0,
          onTap: () => context.push(AppRoutes.notifications),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: c.surface,
          shape: const CircleBorder(),
          elevation: 1,
          shadowColor: c.border,
          child: IconButton(
            tooltip: tooltip,
            icon: Icon(icon, color: c.textPrimary),
            onPressed: onTap,
          ),
        ),
        if (showBadge)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: AppDimensions.badge,
              height: AppDimensions.badge,
              decoration: BoxDecoration(
                color: AppAccents.coral.color,
                shape: BoxShape.circle,
                border: Border.all(color: c.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({required this.balance, required this.net, required this.now});

  final double balance;
  final double net;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final up = net >= 0;
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FinanceStrings.availableBalance,
            style: t.labelLarge?.copyWith(color: c.onInk.withOpacity(0.75)),
          ),
          AppSpacing.vSm,
          MoneyDisplay(amount: balance, size: MoneySize.hero, color: c.onInk),
          AppSpacing.vSm,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: (up ? const Color(0xFF2EE6A6) : const Color(0xFFFF6B6B)).withOpacity(0.18),
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: (up ? const Color(0xFF2EE6A6) : const Color(0xFFFF6B6B)).withOpacity(0.45),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: AppDimensions.iconSm,
                  color: up ? const Color(0xFF2EE6A6) : const Color(0xFFFF6B6B),
                ),
                AppSpacing.hXs,
                Text(
                  '${up ? '+' : '-'}${Formatters.money(net.abs())} ${FinanceStrings.balanceNote}',
                  style: t.labelMedium?.copyWith(
                    color: up ? const Color(0xFF2EE6A6) : const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vLg,
          Row(
            children: [
              Expanded(
                child: RoundAction(
                  icon: Icons.south_west,
                  label: FinanceStrings.quickAddIncome,
                  accentColor: const Color(0xFF2EE6A6),
                  onTap: () => context.push(AppRoutes.transactionNew,
                      extra: TransactionType.income),
                ),
              ),
              Expanded(
                child: RoundAction(
                  icon: Icons.north_east,
                  label: FinanceStrings.quickAddExpense,
                  accentColor: const Color(0xFFFF6B6B),
                  onTap: () => context.push(AppRoutes.transactionNew,
                      extra: TransactionType.expense),
                ),
              ),
              Expanded(
                child: RoundAction(
                  icon: Icons.pie_chart_outline,
                  label: FinanceStrings.quickBudget,
                  accentColor: const Color(0xFF60A5FA),
                  onTap: () => context.go(AppRoutes.budget),
                ),
              ),
              Expanded(
                child: RoundAction(
                  icon: Icons.savings_outlined,
                  label: FinanceStrings.quickSavings,
                  accentColor: const Color(0xFFFBBF24),
                  onTap: () => context.go(AppRoutes.savings),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.amount,
    required this.kind,
  });

  final IconData icon;
  final AppAccent accent;
  final String label;
  final double amount;
  final MoneyKind kind;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccentIconBox(icon: icon, accent: accent, size: 40),
          AppSpacing.vMd,
          Text(label, style: context.text.labelLarge),
          Text(FinanceStrings.thisMonth, style: context.text.bodySmall),
          AppSpacing.vSm,
          MoneyDisplay(amount: amount, kind: kind),
        ],
      ),
    );
  }
}

class _SpendingRibbon extends StatelessWidget {
  const _SpendingRibbon({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final entries = summary.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: FinanceStrings.whereItWent,
          actionLabel: FinanceStrings.details,
          onAction: () => context.push(AppRoutes.reports),
        ),
        AppCard(
          child: Column(
            children: [
              ColorSegmentBar(
                trackColor: c.border,
                segments: [
                  for (final e in entries)
                    ColorSegment(e.value, AppAccents.forCategory(e.key).color),
                ],
              ),
              AppSpacing.vMd,
              for (final e in entries.take(4))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppAccents.forCategory(e.key).color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.hSm,
                      Expanded(child: Text(e.key.label, style: t.bodyMedium)),
                      Text(Formatters.money(e.value), style: t.labelLarge),
                      AppSpacing.hSm,
                      SizedBox(
                        width: 44,
                        child: Text(
                          Formatters.percent(e.value / summary.expense),
                          textAlign: TextAlign.end,
                          style: t.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
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
                    accent: AppAccents.blue,
                    title: AppStrings.emptyBudgetTitle,
                    message: AppStrings.emptyBudgetMessage,
                    actionLabel: AppStrings.createBudget,
                    onAction: () => context.push(AppRoutes.budgetEdit, extra: month),
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
                  ..sort((a, b) => b.currentAmount.compareTo(a.currentAmount));
                if (active.isEmpty) {
                  return _CtaCard(
                    icon: Icons.savings_outlined,
                    accent: AppAccents.amber,
                    title: AppStrings.emptyGoalsTitle,
                    message: AppStrings.emptyGoalsMessage,
                    actionLabel: AppStrings.createGoal,
                    onAction: () => context.push(AppRoutes.goalEdit),
                  );
                }
                final goal = active.first;
                return AppCard(
                  onTap: () => context.go(AppRoutes.savings),
                  child: Row(
                    children: [
                      const AccentIconBox(icon: Icons.flag_outlined, accent: AppAccents.amber),
                      AppSpacing.hMd,
                      Expanded(
                        child: SavingsProgress(
                          label: goal.name,
                          current: goal.currentAmount,
                          target: goal.targetAmount,
                          color: AppAccents.amber.color,
                        ),
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

class _CtaCard extends StatelessWidget {
  const _CtaCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final AppAccent accent;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AccentIconBox(icon: icon, accent: accent),
              AppSpacing.hMd,
              Expanded(child: Text(title, style: context.text.titleMedium)),
            ],
          ),
          AppSpacing.vSm,
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

class _QuickShortcutsSection extends StatelessWidget {
  const _QuickShortcutsSection();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    final shortcuts = [
      (
        icon: Icons.call_split_rounded,
        label: 'Split Bill',
        subtitle: 'Dorm & dining',
        accent: AppAccents.coral,
        onTap: () => SplitBillSheet.show(context),
      ),
      (
        icon: Icons.history,
        label: 'History',
        subtitle: 'All records',
        accent: AppAccents.blue,
        onTap: () => context.go(AppRoutes.activity),
      ),
      (
        icon: Icons.school_outlined,
        label: 'Learning',
        subtitle: 'Finance tips',
        accent: AppAccents.amber,
        onTap: () => context.push(AppRoutes.learning),
      ),
      (
        icon: Icons.rate_review_outlined,
        label: 'Feedback',
        subtitle: 'Share review',
        accent: AppAccents.green,
        onTap: () => context.push(AppRoutes.feedback),
      ),
      (
        icon: Icons.headset_mic_outlined,
        label: 'Support',
        subtitle: 'Get help',
        accent: AppAccents.purple,
        onTap: () => context.push(AppRoutes.support),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.vMd,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (var i = 0; i < shortcuts.length; i++) ...[
                if (i > 0) AppSpacing.hSm,
                SizedBox(
                  width: 96,
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(color: c.border, width: 1.0),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: AppRadius.mdAll,
                      child: InkWell(
                        onTap: shortcuts[i].onTap,
                        borderRadius: AppRadius.mdAll,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                            horizontal: AppSpacing.xs,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AccentIconBox(
                                icon: shortcuts[i].icon,
                                accent: shortcuts[i].accent,
                                size: 38,
                              ),
                              AppSpacing.vSm,
                              Text(
                                shortcuts[i].label,
                                style: t.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                shortcuts[i].subtitle,
                                style: t.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: c.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountsBreakdownSection extends ConsumerWidget {
  const _AccountsBreakdownSection({required this.all, required this.now});

  final List<FinanceTransaction> all;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = FinanceCalculator.modeSummaries(all, month: now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Accounts & Wallets',
          actionLabel: FinanceStrings.seeAll,
          onAction: () => context.go(AppRoutes.activity),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final s in summaries) ...[
                _AccountCard(
                  summary: s,
                  onTap: () {
                    ref
                        .read(transactionFilterProvider.notifier)
                        .setPaymentMode(s.mode);
                    context.go(AppRoutes.activity);
                  },
                ),
                AppSpacing.hSm,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.summary,
    required this.onTap,
  });

  final PaymentModeSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    final accent = switch (summary.mode) {
      PaymentMode.cash => AppAccents.green,
      PaymentMode.card => AppAccents.purple,
      PaymentMode.bankTransfer => AppAccents.blue,
      PaymentMode.wallet => AppAccents.amber,
    };

    return SizedBox(
      width: 220,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AccentIconBox(icon: summary.mode.icon, accent: accent, size: 38),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.mode.label,
                        style: t.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Sum: ${Formatters.money(summary.allTimeBalance)}',
                        style: t.bodySmall?.copyWith(
                          color: summary.allTimeBalance >= 0
                              ? c.textPrimary
                              : AppAccents.coral.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.vMd,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                borderRadius: AppRadius.smAll,
                border: Border.all(color: c.border.withOpacity(0.6)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.south_west, size: 12, color: AppAccents.green.color),
                          const SizedBox(width: 4),
                          Text('Income', style: t.bodySmall?.copyWith(fontSize: 11)),
                        ],
                      ),
                      Text(
                        '+${Formatters.money(summary.income)}',
                        style: t.labelSmall?.copyWith(
                          color: AppAccents.green.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.north_east, size: 12, color: AppAccents.coral.color),
                          const SizedBox(width: 4),
                          Text('Expense', style: t.bodySmall?.copyWith(fontSize: 11)),
                        ],
                      ),
                      Text(
                        '-${Formatters.money(summary.expense)}',
                        style: t.labelSmall?.copyWith(
                          color: AppAccents.coral.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

