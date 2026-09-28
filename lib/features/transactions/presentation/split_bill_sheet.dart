import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../domain/finance_transaction.dart';

enum _TipMode { percent, amount }

class SplitBillSheet extends StatefulWidget {
  const SplitBillSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const SplitBillSheet(),
    );
  }

  @override
  State<SplitBillSheet> createState() => _SplitBillSheetState();
}

class _SplitBillSheetState extends State<SplitBillSheet> {
  final _amountCtrl = TextEditingController();
  final _tipAmountCtrl = TextEditingController();
  final _titleCtrl =
      TextEditingController(text: 'Group dinner / shared expense');
  int _peopleCount = 3;
  _TipMode _tipMode = _TipMode.percent;
  double _tipPercent = 0.0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _tipAmountCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  double get _totalBill => double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

  double get _tipAmount {
    if (_tipMode == _TipMode.percent) {
      return _totalBill * (_tipPercent / 100);
    } else {
      return double.tryParse(_tipAmountCtrl.text.trim()) ?? 0.0;
    }
  }

  double get _totalWithTip => _totalBill + _tipAmount;

  double get _perPersonShare =>
      _peopleCount > 0 ? (_totalWithTip / _peopleCount) : 0.0;

  void _logAsExpense() {
    if (_perPersonShare <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid bill amount.')),
      );
      return;
    }

    final shareAmount = _perPersonShare;
    final tipNote = _tipAmount > 0
        ? ' (incl. ${Formatters.money(_tipAmount)} tip/extra)'
        : '';
    final note =
        '${_titleCtrl.text.trim()} (My share of ${Formatters.money(_totalWithTip)}$tipNote split among $_peopleCount)';

    Navigator.of(context).pop();
    context.push(
      AppRoutes.transactionNew,
      extra: <String, dynamic>{
        'type': TransactionType.expense,
        'amount': double.parse(shareAmount.toStringAsFixed(2)),
        'description': note,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + bottomSafe,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xs,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.group_outlined, color: c.primary),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Split Bill with Friends', style: t.titleLarge),
                      Text(
                        'Dorm, dinner, or shared student expenses',
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.vLg,
            AppTextField(
              label: 'Bill Title / Note',
              controller: _titleCtrl,
              prefixIcon: Icons.receipt_long_outlined,
            ),
            AppSpacing.vMd,
            AppTextField(
              label: 'Total Bill Amount',
              controller: _amountCtrl,
              prefixText: '${Formatters.currentCurrency} ',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            AppSpacing.vMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Split Among Friends', style: t.labelLarge),
                Container(
                  decoration: BoxDecoration(
                    color: c.surfaceElevated,
                    borderRadius: AppRadius.pillAll,
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: _peopleCount > 2
                            ? () => setState(() => _peopleCount--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs),
                        child: Text(
                          '$_peopleCount people',
                          style: t.labelMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: _peopleCount < 20
                            ? () => setState(() => _peopleCount++)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.vMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Tip / Extra (Optional)', style: t.labelLarge),
                Container(
                  decoration: BoxDecoration(
                    color: c.surfaceElevated,
                    borderRadius: AppRadius.pillAll,
                    border: Border.all(color: c.border),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TipModeButton(
                        label: '% Percent',
                        selected: _tipMode == _TipMode.percent,
                        onTap: () =>
                            setState(() => _tipMode = _TipMode.percent),
                      ),
                      _TipModeButton(
                        label: 'Amount (${Formatters.currentCurrency})',
                        selected: _tipMode == _TipMode.amount,
                        onTap: () =>
                            setState(() => _tipMode = _TipMode.amount),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.vSm,
            if (_tipMode == _TipMode.percent) ...[
              Row(
                children: [
                  for (final tip in [0, 5, 10, 15, 20]) ...[
                    if (tip > 0) AppSpacing.hSm,
                    Expanded(
                      child: FilterChip(
                        label: Text('$tip%'),
                        selected: _tipPercent == tip.toDouble(),
                        onSelected: (_) =>
                            setState(() => _tipPercent = tip.toDouble()),
                      ),
                    ),
                  ],
                ],
              ),
              if (_tipPercent > 0 && _totalBill > 0) ...[
                AppSpacing.vXs,
                Text(
                  '${_tipPercent.toInt()}% tip = ${Formatters.money(_tipAmount)}',
                  style: t.bodySmall?.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ] else ...[
              AppTextField(
                label: 'Tip / Extra Amount',
                controller: _tipAmountCtrl,
                prefixText: '${Formatters.currentCurrency} ',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
              ),
              AppSpacing.vXs,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final preset in [50, 100, 200, 500]) ...[
                      ActionChip(
                        label: Text('+${Formatters.currentCurrency} $preset'),
                        onPressed: () {
                          _tipAmountCtrl.text = preset.toString();
                          setState(() {});
                        },
                      ),
                      AppSpacing.hXs,
                    ],
                    if (_tipAmountCtrl.text.isNotEmpty)
                      ActionChip(
                        avatar: const Icon(Icons.close, size: 14),
                        label: const Text('Clear'),
                        onPressed: () {
                          _tipAmountCtrl.clear();
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),
            ],
            AppSpacing.vLg,
            AppCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bill Amount', style: t.bodySmall),
                      Text(
                        Formatters.money(_totalBill),
                        style:
                            t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (_tipAmount > 0) ...[
                    AppSpacing.vXs,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tipMode == _TipMode.percent
                              ? 'Tip (${_tipPercent.toInt()}%)'
                              : 'Tip / Extra Added',
                          style: t.bodySmall,
                        ),
                        Text(
                          '+${Formatters.money(_tipAmount)}',
                          style: t.bodyMedium?.copyWith(
                            color: c.income,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total with Tip', style: t.bodyMedium),
                      Text(
                        Formatters.money(_totalWithTip),
                        style: t.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Personal Share',
                            style: t.titleMedium?.copyWith(color: c.primary),
                          ),
                          Text(
                            '1 of $_peopleCount people',
                            style: t.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      Text(
                        Formatters.money(_perPersonShare),
                        style: t.headlineMedium?.copyWith(
                          color: c.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.vLg,
            AppButton(
              label: 'Record My Share in PennyPal',
              icon: Icons.north_east,
              onPressed: _totalBill > 0 ? _logAsExpense : null,
            ),
            AppSpacing.vLg,
          ],
        ),
      ),
    );
  }
}

class _TipModeButton extends StatelessWidget {
  const _TipModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return InkWell(
      borderRadius: AppRadius.pillAll,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c.primary : Colors.transparent,
          borderRadius: AppRadius.pillAll,
        ),
        child: Text(
          label,
          style: t.bodySmall?.copyWith(
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? c.onPrimary : c.textSecondary,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

