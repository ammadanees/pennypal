import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_categories.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/finance_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../cards/data/card_repository.dart';
import '../../cards/domain/payment_card.dart';
import '../data/transaction_repository.dart';
import '../domain/finance_transaction.dart';
import '../domain/transaction_filter.dart';
import 'split_bill_sheet.dart';
import 'transaction_detail_sheet.dart';
import 'transaction_display.dart';
import 'transaction_filter_controller.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearAll() {
    _search.clear();
    ref.read(transactionFilterProvider.notifier).clear();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final current = ref.read(transactionFilterProvider).range;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: current == null
          ? null
          : DateTimeRange(start: current.start, end: current.end),
    );
    if (picked == null) return;
    ref
        .read(transactionFilterProvider.notifier)
        .setRange(DateRange(picked.start, picked.end));
  }

  void _showAddMenu() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.colors.expense.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.north_east,
                    size: 20, color: context.colors.expense),
              ),
              title: const Text(FinanceStrings.quickAddExpense),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push(AppRoutes.transactionNew,
                    extra: TransactionType.expense);
              },
            ),
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.colors.income.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.south_west,
                    size: 20, color: context.colors.income),
              ),
              title: const Text(FinanceStrings.quickAddIncome),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push(AppRoutes.transactionNew,
                    extra: TransactionType.income);
              },
            ),
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.call_split_rounded,
                    size: 20, color: context.colors.primary),
              ),
              title: const Text('Split Bill with Roommates'),
              subtitle: const Text('Calculate per-person share & tip'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                SplitBillSheet.show(context);
              },
            ),
            AppSpacing.vSm,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(transactionFilterProvider);
    final notifier = ref.read(transactionFilterProvider.notifier);
    final results = ref.watch(filteredTransactionsProvider);
    final cards = ref.watch(cardsProvider).valueOrNull ?? const <PaymentCard>[];
    final activeCard = cards.where((c) => c.id == filter.cardId).firstOrNull;

    final rangeLabel = filter.range == null
        ? FinanceStrings.filterAnyDate
        : '${DateFormat('d MMM').format(filter.range!.start)} - '
            '${DateFormat('d MMM').format(filter.range!.end)}';

    return AppScaffold(
      title: FinanceStrings.activityTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.call_split_rounded),
          tooltip: 'Split Bill with Roommates',
          onPressed: () => SplitBillSheet.show(context),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        tooltip: FinanceStrings.add,
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          AppSpacing.vSm,
          AppTextField(
            label: FinanceStrings.searchLabel,
            controller: _search,
            prefixIcon: Icons.search,
            textInputAction: TextInputAction.search,
            onChanged: notifier.setQuery,
          ),
          AppSpacing.vSm,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AppChip(
                  label: FinanceStrings.filterAll,
                  selected: filter.type == null &&
                      filter.category == null &&
                      filter.paymentMode == null &&
                      filter.cardId == null,
                  onSelected: () {
                    notifier.setType(null);
                    notifier.setCategory(null);
                    notifier.setPaymentMode(null);
                  },
                ),
                AppSpacing.hSm,
                AppChip(
                  label: FinanceStrings.filterIncome,
                  icon: Icons.south_west,
                  selected: filter.type == TransactionType.income,
                  onSelected: () => notifier.setType(TransactionType.income),
                ),
                AppSpacing.hSm,
                AppChip(
                  label: FinanceStrings.filterExpense,
                  icon: Icons.north_east,
                  selected: filter.type == TransactionType.expense,
                  onSelected: () => notifier.setType(TransactionType.expense),
                ),
                AppSpacing.hSm,
                AppChip(
                  label: rangeLabel,
                  icon: Icons.event_outlined,
                  selected: filter.range != null,
                  onSelected: _pickRange,
                ),
                for (final mode in PaymentMode.values) ...[
                  if (mode == PaymentMode.card && cards.length > 1) ...[
                    for (final card in cards) ...[
                      AppSpacing.hSm,
                      AppChip(
                        label: card.name,
                        icon: Icons.credit_card,
                        selected: filter.paymentMode == PaymentMode.card &&
                            filter.cardId == card.id,
                        onSelected: () {
                          if (filter.paymentMode == PaymentMode.card &&
                              filter.cardId == card.id) {
                            notifier.setPaymentMode(null);
                          } else {
                            notifier.setPaymentMode(PaymentMode.card,
                                cardId: card.id);
                          }
                        },
                      ),
                    ],
                  ] else ...[
                    AppSpacing.hSm,
                    AppChip(
                      label: mode.label,
                      icon: mode.icon,
                      selected:
                          filter.paymentMode == mode && filter.cardId == null,
                      onSelected: () => notifier.setPaymentMode(
                        filter.paymentMode == mode ? null : mode,
                      ),
                    ),
                  ],
                ],
                for (final category in ExpenseCategory.values) ...[
                  AppSpacing.hSm,
                  AppChip(
                    label: category.label,
                    icon: category.icon,
                    selected: filter.category == category,
                    onSelected: () => notifier.setCategory(
                      filter.category == category ? null : category,
                    ),
                  ),
                ],
                if (filter.isActive) ...[
                  AppSpacing.hSm,
                  AppChip(
                    label: FinanceStrings.clearFilters,
                    icon: Icons.close,
                    selected: false,
                    onSelected: _clearAll,
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.vSm,
          Expanded(
            child: AsyncValueView<List<FinanceTransaction>>(
              value: results,
              onRetry: () => ref.invalidate(transactionsProvider),
              data: (list) {
                if (list.isEmpty) {
                  return filter.isActive
                      ? AppEmptyState(
                          icon: Icons.search_off,
                          title: FinanceStrings.noMatchTitle,
                          message: FinanceStrings.noMatchMessage,
                          actionLabel: FinanceStrings.clearFilters,
                          onAction: _clearAll,
                        )
                      : AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: AppStrings.emptyTransactionsTitle,
                          message: AppStrings.emptyTransactionsMessage,
                          actionLabel: AppStrings.addExpense,
                          onAction: () => context.push(
                            AppRoutes.transactionNew,
                            extra: TransactionType.expense,
                          ),
                        );
                }
                return Column(
                  children: [
                    _AccountSummaryCard(
                      transactions: list,
                      activeMode: filter.paymentMode,
                      activeCardName: activeCard?.name,
                    ),
                    Expanded(
                      child: _TransactionList(transactions: list),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({
    required this.transactions,
    required this.activeMode,
    this.activeCardName,
  });

  final List<FinanceTransaction> transactions;
  final PaymentMode? activeMode;
  final String? activeCardName;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    final inTotal = transactions
        .where((e) => e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final exTotal = transactions
        .where((e) => !e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final netSum = inTotal - exTotal;

    final title = activeCardName != null
        ? '$activeCardName Overview'
        : activeMode != null
            ? '${activeMode!.label} Overview'
            : 'Filtered Summary';
    final icon = activeCardName != null
        ? Icons.credit_card
        : (activeMode?.icon ?? Icons.account_balance_wallet_outlined);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: c.textSecondary),
                AppSpacing.hSm,
                Expanded(
                  child: Text(
                    title,
                    style: t.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  'Sum: ${Formatters.money(netSum)}',
                  style: t.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: netSum >= 0 ? c.income : c.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.income.withOpacity(0.08),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.south_west, size: 12, color: c.income),
                            const SizedBox(width: 4),
                            Text('Income',
                                style: t.bodySmall?.copyWith(fontSize: 11)),
                          ],
                        ),
                        Text(
                          '+${Formatters.money(inTotal)}',
                          style: t.labelSmall?.copyWith(
                            color: c.income,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.expense.withOpacity(0.08),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.north_east, size: 12, color: c.expense),
                            const SizedBox(width: 4),
                            Text('Expense',
                                style: t.bodySmall?.copyWith(fontSize: 11)),
                          ],
                        ),
                        Text(
                          '-${Formatters.money(exTotal)}',
                          style: t.labelSmall?.copyWith(
                            color: c.expense,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayGroup {
  _DayGroup(this.day);

  final DateTime day;
  final List<FinanceTransaction> items = [];
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final List<FinanceTransaction> transactions;

  List<_DayGroup> _group() {
    final groups = <_DayGroup>[];
    for (final t in transactions) {
      final day = AppDates.dateOnly(t.date);
      if (groups.isEmpty || groups.last.day != day) groups.add(_DayGroup(day));
      groups.last.items.add(t);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _group();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppDimensions.fabClearance),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.md,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                Formatters.dayLabel(group.day),
                style: context.text.labelLarge,
              ),
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < group.items.length; i++) ...[
                    if (i > 0) const Divider(),
                    TransactionListTile(
                      transaction: group.items[i],
                      onTap: () =>
                          showTransactionDetail(context, group.items[i]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
