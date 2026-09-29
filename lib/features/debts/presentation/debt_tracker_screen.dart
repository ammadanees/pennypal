import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/finance_strings.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/money_display.dart';
import '../data/debt_repository.dart';
import '../domain/debt_record.dart';
import 'add_debt_sheet.dart';

enum _DebtFilter { all, lent, borrowed, settled }

class DebtTrackerScreen extends ConsumerStatefulWidget {
  const DebtTrackerScreen({super.key});

  @override
  ConsumerState<DebtTrackerScreen> createState() => _DebtTrackerScreenState();
}

class _DebtTrackerScreenState extends ConsumerState<DebtTrackerScreen> {
  _DebtFilter _filter = _DebtFilter.all;

  void _shareReminder(DebtRecord debt, String currency) {
    HapticFeedback.selectionClick();
    final amountFormatted = Formatters.money(debt.amount, currency: currency);
    final String message;
    if (debt.isOwedToMe) {
      message =
          'Hey ${debt.personName}! Just a friendly reminder from PennyPal regarding $amountFormatted'
          '${debt.note.isNotEmpty ? " for ${debt.note}" : ""}. Let me know whenever you\'re settling up! 😊';
    } else {
      message =
          'Hey ${debt.personName}! Checking in from PennyPal regarding the $amountFormatted'
          '${debt.note.isNotEmpty ? " for ${debt.note}" : ""} I owe you. Let me know the best way to send it!';
    }
    Share.share(message, subject: 'PennyPal Reminder');
  }

  Future<void> _deleteDebt(DebtRecord debt) async {
    final ok = await confirmAction(
      context,
      title: 'Delete Record',
      message: 'Delete the loan record for ${debt.personName}?',
      confirmLabel: FinanceStrings.delete,
    );
    if (!ok || !mounted) return;
    await ref.read(debtRepositoryProvider).delete(debt.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final currency = ref.watch(currencyProvider);
    final debtsAsync = ref.watch(debtsProvider);

    return AppScaffold(
      title: 'Borrow & Lend Tracker',
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => showAddDebtSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
      body: AsyncValueView<List<DebtRecord>>(
        value: debtsAsync,
        onRetry: () => ref.invalidate(debtsProvider),
        data: (allDebts) {
          final activeDebts = allDebts.where((d) => !d.isSettled).toList();
          final totalOwedToMe = activeDebts
              .where((d) => d.type == DebtType.lent)
              .fold<double>(0, (sum, d) => sum + d.amount);
          final totalIOwe = activeDebts
              .where((d) => d.type == DebtType.borrowed)
              .fold<double>(0, (sum, d) => sum + d.amount);
          final netBalance = totalOwedToMe - totalIOwe;

          final filtered = allDebts.where((d) {
            return switch (_filter) {
              _DebtFilter.all => !d.isSettled,
              _DebtFilter.lent => !d.isSettled && d.type == DebtType.lent,
              _DebtFilter.borrowed =>
                !d.isSettled && d.type == DebtType.borrowed,
              _DebtFilter.settled => d.isSettled,
            };
          }).toList();

          return ListView(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppDimensions.fabClearance + 20,
            ),
            children: [
              // Summary Banner Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Net Balance', style: t.labelLarge),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (netBalance >= 0 ? c.income : c.expense)
                                .withOpacity(0.12),
                            borderRadius: AppRadius.pillAll,
                          ),
                          child: Text(
                            netBalance >= 0
                                ? '+$currency ${Formatters.number(netBalance)} to receive'
                                : '-$currency ${Formatters.number(netBalance.abs())} to pay',
                            style: t.labelSmall?.copyWith(
                              color: netBalance >= 0 ? c.income : c.expense,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vMd,
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.call_made_rounded,
                                      size: 14, color: c.income),
                                  const SizedBox(width: 4),
                                  Text('Owed to You', style: t.bodySmall),
                                ],
                              ),
                              const SizedBox(height: 2),
                              MoneyDisplay(
                                amount: totalOwedToMe,
                                size: MoneySize.title,
                                kind: MoneyKind.income,
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 38, color: c.border),
                        AppSpacing.hMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.call_received_rounded,
                                      size: 14, color: c.expense),
                                  const SizedBox(width: 4),
                                  Text('You Owe', style: t.bodySmall),
                                ],
                              ),
                              const SizedBox(height: 2),
                              MoneyDisplay(
                                amount: totalIOwe,
                                size: MoneySize.title,
                                kind: MoneyKind.expense,
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

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(
                      label: 'Active (${activeDebts.length})',
                      selected: _filter == _DebtFilter.all,
                      onTap: () => setState(() => _filter = _DebtFilter.all),
                    ),
                    AppSpacing.hSm,
                    _filterChip(
                      label: 'Owed to Me',
                      selected: _filter == _DebtFilter.lent,
                      onTap: () => setState(() => _filter = _DebtFilter.lent),
                    ),
                    AppSpacing.hSm,
                    _filterChip(
                      label: 'I Owe',
                      selected: _filter == _DebtFilter.borrowed,
                      onTap: () =>
                          setState(() => _filter = _DebtFilter.borrowed),
                    ),
                    AppSpacing.hSm,
                    _filterChip(
                      label: 'Settled',
                      selected: _filter == _DebtFilter.settled,
                      onTap: () =>
                          setState(() => _filter = _DebtFilter.settled),
                    ),
                  ],
                ),
              ),
              AppSpacing.vMd,

              if (filtered.isEmpty)
                AppCard(
                  child: AppEmptyState(
                    icon: Icons.handshake_outlined,
                    title: _filter == _DebtFilter.settled
                        ? 'No settled records'
                        : 'No active debts',
                    message: _filter == _DebtFilter.settled
                        ? 'Settled loans and repayments will appear here.'
                        : 'Record money lent to friends or borrowed for meals & notes.',
                    actionLabel: 'Add Record',
                    onAction: () => showAddDebtSheet(context),
                  ),
                )
              else
                for (final debt in filtered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _DebtTile(
                      debt: debt,
                      onToggleSettled: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(debtRepositoryProvider)
                            .toggleSettled(debt);
                      },
                      onShareReminder: () => _shareReminder(debt, currency),
                      onEdit: () =>
                          showAddDebtSheet(context, existing: debt),
                      onDelete: () => _deleteDebt(debt),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final c = context.colors;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: c.primarySoft,
      labelStyle: TextStyle(
        color: selected ? c.primary : c.textPrimary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({
    required this.debt,
    required this.onToggleSettled,
    required this.onShareReminder,
    required this.onEdit,
    required this.onDelete,
  });

  final DebtRecord debt;
  final VoidCallback onToggleSettled;
  final VoidCallback onShareReminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final isPastDue = debt.dueDate != null &&
        DateTime.now().isAfter(debt.dueDate!) &&
        !debt.isSettled;

    final initial = debt.personName.trim().isNotEmpty
        ? debt.personName.trim()[0].toUpperCase()
        : '?';

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: debt.isSettled
                    ? c.surfaceElevated
                    : (debt.isOwedToMe
                        ? c.income.withOpacity(0.15)
                        : c.expense.withOpacity(0.15)),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: debt.isSettled
                        ? c.textMuted
                        : (debt.isOwedToMe ? c.income : c.expense),
                  ),
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.personName,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: debt.isSettled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (debt.note.isNotEmpty)
                      Text(
                        debt.note,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    if (debt.dueDate != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 12,
                            color: isPastDue ? c.expense : c.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPastDue
                                ? 'Overdue: ${AppDates.shortDate(debt.dueDate!)}'
                                : 'Due: ${AppDates.shortDate(debt.dueDate!)}',
                            style: t.bodySmall?.copyWith(
                              fontSize: 11,
                              color: isPastDue ? c.expense : c.textMuted,
                              fontWeight: isPastDue
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyDisplay(
                    amount: debt.amount,
                    size: MoneySize.title,
                    kind: debt.isSettled
                        ? MoneyKind.neutral
                        : (debt.isOwedToMe
                            ? MoneyKind.income
                            : MoneyKind.expense),
                  ),
                  Text(
                    debt.isSettled ? 'Settled' : debt.type.label,
                    style: t.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: debt.isSettled
                          ? c.textMuted
                          : (debt.isOwedToMe ? c.income : c.expense),
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
              TextButton.icon(
                onPressed: onToggleSettled,
                icon: Icon(
                  debt.isSettled
                      ? Icons.undo_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 16,
                  color: debt.isSettled ? c.textMuted : c.primary,
                ),
                label: Text(
                  debt.isSettled ? 'Reopen' : 'Mark Settled',
                  style: TextStyle(
                    fontSize: 12,
                    color: debt.isSettled ? c.textMuted : c.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
              Row(
                children: [
                  if (!debt.isSettled)
                    IconButton(
                      tooltip: 'Share Reminder',
                      icon: const Icon(Icons.share_outlined, size: 18),
                      visualDensity: VisualDensity.compact,
                      onPressed: onShareReminder,
                    ),
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
