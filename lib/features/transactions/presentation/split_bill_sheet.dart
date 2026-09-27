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
  final _titleCtrl = TextEditingController(text: 'Group dinner / shared expense');
  int _peopleCount = 3;
  double _tipPercent = 0.0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  double get _totalBill => double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

  double get _totalWithTip => _totalBill * (1 + (_tipPercent / 100));

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
    final note = '${_titleCtrl.text.trim()} (My share of ${Formatters.money(_totalWithTip)} split among $_peopleCount)';

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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: Text(
                          '$_peopleCount people',
                          style: t.labelMedium?.copyWith(fontWeight: FontWeight.bold),
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
            Text('Add Tip / Extra (Optional)', style: t.labelMedium),
            AppSpacing.vXs,
            Row(
              children: [
                for (final tip in [0, 5, 10, 15]) ...[
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
            AppSpacing.vLg,
            AppCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total with Tip', style: t.bodyMedium),
                      Text(
                        Formatters.money(_totalWithTip),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg),
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
                            'Exact share to record',
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
