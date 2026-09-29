import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/constants/finance_strings.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/id_generator.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/money_display.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_record.dart';
import 'add_subscription_sheet.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  Future<void> _payAndLog(SubscriptionRecord sub) async {
    HapticFeedback.mediumImpact();
    final ok = await confirmAction(
      context,
      title: 'Pay & Log Expense',
      message:
          'Mark "${sub.name}" as paid for this month and record a ${Formatters.money(sub.amount)} expense transaction in PennyPal?',
      confirmLabel: 'Pay & Log',
    );
    if (!ok || !mounted) return;

    // 1. Mark subscription paid
    await ref.read(subscriptionRepositoryProvider).markPaid(sub);

    // 2. Automatically log transaction in PennyPal
    final tx = FinanceTransaction(
      id: IdGenerator.next(),
      type: TransactionType.expense,
      amount: sub.amount,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      category: sub.category,
      description: '${sub.name} (Recurring Subscription)',
      paymentMode: PaymentMode.bankTransfer,
    );
    await ref.read(transactionRepositoryProvider).save(tx);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paid & recorded ${sub.name} in transactions!'),
      ),
    );
  }

  Future<void> _deleteSub(SubscriptionRecord sub) async {
    final ok = await confirmAction(
      context,
      title: 'Delete Subscription',
      message: 'Delete recurring tracker for "${sub.name}"?',
      confirmLabel: FinanceStrings.delete,
    );
    if (!ok || !mounted) return;
    await ref.read(subscriptionRepositoryProvider).delete(sub.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final currency = ref.watch(currencyProvider);
    final subsAsync = ref.watch(subscriptionsProvider);
    final now = DateTime.now();

    return AppScaffold(
      title: 'Subscriptions & Bills',
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => showAddSubscriptionSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Bill'),
      ),
      body: AsyncValueView<List<SubscriptionRecord>>(
        value: subsAsync,
        onRetry: () => ref.invalidate(subscriptionsProvider),
        data: (subs) {
          final totalMonthly = subs.fold<double>(
            0,
            (sum, s) =>
                sum + (s.billingCycle == 'yearly' ? s.amount / 12 : s.amount),
          );

          final unpaid = subs.where((s) => !s.isPaidForMonth(now)).toList();
          final nextDue = unpaid.isNotEmpty
              ? (unpaid..sort((a, b) => a.daysUntilDue(now).compareTo(b.daysUntilDue(now)))).first
              : null;

          return ListView(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppDimensions.fabClearance + 20,
            ),
            children: [
              // Monthly Commitments Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Monthly Commitments', style: t.labelLarge),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: c.primarySoft,
                            borderRadius: AppRadius.pillAll,
                          ),
                          child: Text(
                            '${subs.length} Active',
                            style: t.labelSmall?.copyWith(
                              color: c.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vSm,
                    Text(
                      '$currency ${Formatters.number(totalMonthly)} / mo',
                      style: t.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: c.primary,
                      ),
                    ),
                    AppSpacing.vXs,
                    Text(
                      'Fixed monthly spending dedicated to student subscriptions, bills & rent.',
                      style: t.bodySmall,
                    ),
                    if (nextDue != null) ...[
                      AppSpacing.vMd,
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm + 2),
                        decoration: BoxDecoration(
                          color: (nextDue.daysUntilDue(now) <= 3
                                  ? c.expense
                                  : c.primary)
                              .withOpacity(0.08),
                          borderRadius: AppRadius.mdAll,
                          border: Border.all(
                            color: (nextDue.daysUntilDue(now) <= 3
                                    ? c.expense
                                    : c.primary)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              nextDue.daysUntilDue(now) <= 3
                                  ? Icons.warning_amber_rounded
                                  : Icons.notifications_active_outlined,
                              size: 18,
                              color: nextDue.daysUntilDue(now) <= 3
                                  ? c.expense
                                  : c.primary,
                            ),
                            AppSpacing.hSm,
                            Expanded(
                              child: Text(
                                nextDue.daysUntilDue(now) == 0
                                    ? '${nextDue.name} is due today!'
                                    : '${nextDue.name} due in ${nextDue.daysUntilDue(now)} days',
                                style: t.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: nextDue.daysUntilDue(now) <= 3
                                      ? c.expense
                                      : c.primary,
                                ),
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

              if (subs.isEmpty)
                AppCard(
                  child: AppEmptyState(
                    icon: Icons.repeat_on_outlined,
                    title: 'No recurring bills',
                    message:
                        'Add Spotify, Netflix, Hostel Rent, or Tuition installments to track your monthly commitments.',
                    actionLabel: 'Add Subscription',
                    onAction: () => showAddSubscriptionSheet(context),
                  ),
                )
              else ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text('Your Subscriptions', style: t.titleMedium),
                ),
                AppSpacing.vSm,
                for (final sub in subs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _SubscriptionTile(
                      sub: sub,
                      now: now,
                      onPay: () => _payAndLog(sub),
                      onEdit: () =>
                          showAddSubscriptionSheet(context, existing: sub),
                      onDelete: () => _deleteSub(sub),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({
    required this.sub,
    required this.now,
    required this.onPay,
    required this.onEdit,
    required this.onDelete,
  });

  final SubscriptionRecord sub;
  final DateTime now;
  final VoidCallback onPay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final isPaid = sub.isPaidForMonth(now);
    final daysUntil = sub.daysUntilDue(now);

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isPaid
                      ? c.income.withOpacity(0.12)
                      : c.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  sub.category.icon,
                  color: isPaid ? c.income : c.primary,
                  size: 22,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.name,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Day ${sub.dueDay} of month • ${sub.category.label}',
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyDisplay(
                    amount: sub.amount,
                    size: MoneySize.title,
                    kind: MoneyKind.expense,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? c.income.withOpacity(0.12)
                          : (daysUntil <= 3
                              ? c.expense.withOpacity(0.12)
                              : c.surfaceElevated),
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Text(
                      isPaid
                          ? 'Paid this month'
                          : (daysUntil == 0
                              ? 'Due Today'
                              : 'Due in $daysUntil d'),
                      style: t.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPaid
                            ? c.income
                            : (daysUntil <= 3 ? c.expense : c.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isPaid)
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: c.income),
                    const SizedBox(width: 4),
                    Text(
                      'Paid on ${AppDates.shortDate(sub.lastPaidDate!)}',
                      style: t.bodySmall?.copyWith(
                        fontSize: 11,
                        color: c.income,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                TextButton.icon(
                  onPressed: onPay,
                  icon: const Icon(Icons.payment_rounded, size: 16),
                  label: const Text(
                    'Pay & Log Expense',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: c.textMuted),
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
