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
import '../../../shared/widgets/adaptive_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/savings_progress.dart';
import '../../../shared/widgets/section_header.dart';
import '../data/savings_repository.dart';
import '../domain/savings_calculator.dart';
import '../domain/savings_goal.dart';
import 'contribute_sheet.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: FinanceStrings.savingsTitle,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.goalEdit),
        icon: const Icon(Icons.add),
        label: const Text(FinanceStrings.newGoal),
      ),
      body: AsyncValueView<List<SavingsGoal>>(
        value: ref.watch(savingsGoalsProvider),
        onRetry: () => ref.invalidate(savingsGoalsProvider),
        data: (goals) {
          if (goals.isEmpty) {
            return AppEmptyState(
              icon: Icons.savings_outlined,
              title: AppStrings.emptyGoalsTitle,
              message: AppStrings.emptyGoalsMessage,
              actionLabel: AppStrings.createGoal,
              onAction: () => context.push(AppRoutes.goalEdit),
            );
          }
          final active = goals.where((g) => !g.isCompleted).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final done = goals.where((g) => g.isCompleted).toList()
            ..sort((a, b) => (b.completedAt ?? b.createdAt)
                .compareTo(a.completedAt ?? a.createdAt));

          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 800 ? 2 : 1;
              return ListView(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppDimensions.fabClearance,
                ),
                children: [
                  if (active.isEmpty)
                    AppCard(
                      child: Text(
                        FinanceStrings.noActiveGoals,
                        style: context.text.bodyMedium,
                      ),
                    )
                  else
                    AdaptiveGrid(
                      columns: columns,
                      children: [for (final g in active) _GoalCard(goal: g)],
                    ),
                  if (done.isNotEmpty) ...[
                    const SectionHeader(title: FinanceStrings.goalHistory),
                    AdaptiveGrid(
                      columns: columns,
                      children: [for (final g in done) _HistoryCard(goal: g)],
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

enum _GoalMenu { edit, delete }

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final SavingsGoal goal;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await confirmAction(
      context,
      title: FinanceStrings.deleteGoalTitle,
      message: FinanceStrings.deleteGoalMessage,
      confirmLabel: FinanceStrings.delete,
    );
    if (!ok || !context.mounted) return;
    await ref.read(savingsRepositoryProvider).delete(goal.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(FinanceStrings.goalDeleted)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final t = context.text;
    final p = SavingsCalculator.progress(goal);
    final messageIndex = p.ratio >= 1 ? 4 : (p.ratio * 4).floor().clamp(0, 3);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppDimensions.leadingIcon,
                height: AppDimensions.leadingIcon,
                decoration: BoxDecoration(
                  color: c.savings.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.flag_outlined,
                    size: AppDimensions.iconMd, color: c.savings),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name,
                        style: t.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      goal.pending
                          ? FinanceStrings.waitingToSync
                          : (goal.targetDate == null
                              ? ''
                              : '${FinanceStrings.labelGoalDate}: '
                                  '${AppDates.shortDate(goal.targetDate!)}'),
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_GoalMenu>(
                tooltip: 'More',
                onSelected: (action) {
                  switch (action) {
                    case _GoalMenu.edit:
                      context.push(AppRoutes.goalEdit, extra: goal);
                    case _GoalMenu.delete:
                      _delete(context, ref);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _GoalMenu.edit,
                    child: Text(FinanceStrings.editGoal),
                  ),
                  PopupMenuItem(
                    value: _GoalMenu.delete,
                    child: Text(FinanceStrings.delete),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.vMd,
          SavingsProgress(
              current: goal.currentAmount, target: goal.targetAmount),
          AppSpacing.vMd,
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: FinanceStrings.remaining,
                  value: Formatters.money(p.remaining),
                ),
              ),
              Expanded(
                child: _Stat(
                  label: FinanceStrings.monthly,
                  value: goal.monthlyContribution > 0
                      ? Formatters.money(goal.monthlyContribution)
                      : FinanceStrings.notSet,
                ),
              ),
            ],
          ),
          if (p.estimatedCompletion != null) ...[
            AppSpacing.vMd,
            Text(
              FinanceStrings.estimate(
                Formatters.money(goal.monthlyContribution),
                AppDates.monthLabel(p.estimatedCompletion!),
              ),
              style: t.bodyMedium,
            ),
            if (p.onTrack != null) ...[
              AppSpacing.vXs,
              Row(
                children: [
                  Icon(
                    p.onTrack!
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_outlined,
                    size: AppDimensions.iconSm,
                    color: p.onTrack! ? c.success : c.warning,
                  ),
                  AppSpacing.hXs,
                  Expanded(
                    child: Text(
                      p.onTrack!
                          ? FinanceStrings.onTrack
                          : FinanceStrings.behind,
                      style: t.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (p.onTrack == false &&
                p.neededPerMonth != null &&
                goal.targetDate != null) ...[
              AppSpacing.vXs,
              Text(
                FinanceStrings.neededToFinish(
                  Formatters.money(p.neededPerMonth!),
                  AppDates.shortDate(goal.targetDate!),
                ),
                style: t.bodySmall,
              ),
            ],
          ],
          AppSpacing.vMd,
          _Milestones(reached: p.milestonesReached),
          AppSpacing.vSm,
          Text(FinanceStrings.goalMessages[messageIndex], style: t.bodySmall),
          AppSpacing.vMd,
          AppButton(
            label: FinanceStrings.addMoney,
            icon: Icons.add,
            variant: AppButtonVariant.tonal,
            onPressed: () => showContributeSheet(context, goal),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.bodySmall),
        Text(value, style: context.text.titleMedium),
      ],
    );
  }
}

class _Milestones extends StatelessWidget {
  const _Milestones({required this.reached});

  final List<int> reached;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        for (final m in SavingsCalculator.milestones)
          Expanded(
            child: Semantics(
              label:
                  '$m percent milestone ${reached.contains(m) ? 'reached' : 'not reached'}',
              excludeSemantics: true,
              child: Column(
                children: [
                  Icon(
                    reached.contains(m)
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: AppDimensions.iconMd,
                    color: reached.contains(m) ? c.savings : c.textMuted,
                  ),
                  Text(FinanceStrings.milestone(m),
                      style: context.text.bodySmall),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.emoji_events_outlined, color: c.savings),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: t.titleMedium),
                Text(
                  '${FinanceStrings.completedOn}'
                  '${goal.completedAt == null ? '' : ' ${AppDates.shortDate(goal.completedAt!)}'}',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
          Text(Formatters.money(goal.targetAmount), style: t.labelLarge),
        ],
      ),
    );
  }
}
