import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/constants/finance_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';

/// Create or edit the budget for one month.
class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({super.key, required this.month, this.existing});

  final DateTime month;
  final Budget? existing;

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _total;
  late final Map<ExpenseCategory, TextEditingController> _limits;
  late double _threshold;
  String? _limitError;

  bool get _isEditing => widget.existing != null;

  static String _plain(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toString();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _total = TextEditingController(text: e == null ? '' : _plain(e.totalAmount));
    _limits = {
      for (final cat in ExpenseCategory.values)
        cat: TextEditingController(
          text: e?.categoryLimits[cat] == null ? '' : _plain(e!.categoryLimits[cat]!),
        ),
    };
    _threshold = e?.alertThreshold ?? 0.8;
  }

  @override
  void dispose() {
    _total.dispose();
    for (final controller in _limits.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final total = double.parse(_total.text.trim());
    final limits = <ExpenseCategory, double>{
      for (final entry in _limits.entries)
        if ((double.tryParse(entry.value.text.trim()) ?? 0) > 0)
          entry.key: double.parse(entry.value.text.trim()),
    };
    final sum = limits.values.fold<double>(0, (a, b) => a + b);
    if (sum > total) {
      setState(() => _limitError = FinanceStrings.limitsTooHigh);
      return;
    }
    setState(() => _limitError = null);

    final budget = Budget(
      month: widget.month,
      totalAmount: total,
      categoryLimits: limits,
      alertThreshold: _threshold,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    await ref.read(budgetRepositoryProvider).save(budget);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(FinanceStrings.budgetSaved)),
    );
    context.pop();
  }

  Future<void> _delete() async {
    final ok = await confirmAction(
      context,
      title: FinanceStrings.budgetDeleteTitle,
      message: FinanceStrings.budgetDeleteMessage,
      confirmLabel: FinanceStrings.delete,
    );
    if (!ok || !mounted) return;
    await ref.read(budgetRepositoryProvider).delete(widget.existing!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(FinanceStrings.budgetDeleted)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return AppScaffold(
      title: _isEditing
          ? FinanceStrings.budgetFormEdit
          : FinanceStrings.budgetFormNew,
      actions: [
        if (_isEditing)
          IconButton(
            tooltip: FinanceStrings.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
      ],
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            Text(AppDates.monthLabel(widget.month), style: t.headlineMedium),
            AppSpacing.vMd,
            AppTextField(
              label: FinanceStrings.labelBudgetTotal,
              controller: _total,
              prefixText: 'Rs. ',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: AppInputFormatters.amount,
              textInputAction: TextInputAction.next,
              validator: Validators.amount,
            ),
            AppSpacing.vLg,
            Text(FinanceStrings.categoryLimits, style: t.titleMedium),
            AppSpacing.vSm,
            for (final cat in ExpenseCategory.values) ...[
              AppTextField(
                label: cat.label,
                controller: _limits[cat],
                prefixIcon: cat.icon,
                prefixText: 'Rs. ',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: AppInputFormatters.amount,
                textInputAction: TextInputAction.next,
                validator: Validators.optionalAmount,
              ),
              AppSpacing.vSm,
            ],
            if (_limitError != null)
              Text(_limitError!, style: t.bodySmall?.copyWith(color: c.error)),
            AppSpacing.vMd,
            Row(
              children: [
                Expanded(child: Text(FinanceStrings.alertAt, style: t.titleMedium)),
                Text(Formatters.percent(_threshold), style: t.labelLarge),
              ],
            ),
            Slider(
              value: _threshold,
              min: 0.5,
              max: 1.0,
              divisions: 10,
              label: Formatters.percent(_threshold),
              onChanged: (v) => setState(() => _threshold = v),
            ),
            AppSpacing.vLg,
            AppButton(label: FinanceStrings.save, onPressed: _save),
            AppSpacing.vLg,
          ],
        ),
      ),
    );
  }
}
