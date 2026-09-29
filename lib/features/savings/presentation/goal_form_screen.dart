import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/finance_strings.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../data/savings_repository.dart';
import '../domain/savings_goal.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key, this.existing});

  final SavingsGoal? existing;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _current;
  late final TextEditingController _monthly;
  DateTime? _targetDate;
  bool _dateMissing = false;

  bool get _isEditing => widget.existing != null;

  static String _plain(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toString();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _target =
        TextEditingController(text: e == null ? '' : _plain(e.targetAmount));
    _current =
        TextEditingController(text: e == null ? '' : _plain(e.currentAmount));
    _monthly = TextEditingController(
      text: (e == null || e.monthlyContribution <= 0)
          ? ''
          : _plain(e.monthlyContribution),
    );
    _targetDate = e?.targetDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _current.dispose();
    _monthly.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? AppDates.addMonths(now, 6),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
        _dateMissing = false;
      });
    }
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (_targetDate == null) setState(() => _dateMissing = true);
    if (!valid || _targetDate == null) return;

    final existing = widget.existing;
    final current = double.tryParse(_current.text.trim()) ?? 0;
    final goal = SavingsGoal(
      id: existing?.id ?? IdGenerator.next(),
      name: _name.text.trim(),
      targetAmount: double.parse(_target.text.trim()),
      currentAmount: current,
      monthlyContribution: double.tryParse(_monthly.text.trim()) ?? 0,
      status: GoalStatus.active,
      createdAt: existing?.createdAt ?? DateTime.now(),
      targetDate: _targetDate,
    ).withSaved(current);

    await ref.read(savingsRepositoryProvider).save(goal);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(FinanceStrings.goalSaved)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final t = context.text;
    return AppScaffold(
      title:
          _isEditing ? FinanceStrings.goalFormEdit : FinanceStrings.goalFormNew,
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            AppTextField(
              label: FinanceStrings.labelGoalName,
              controller: _name,
              prefixIcon: Icons.flag_outlined,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  Validators.required(v, 'goal name') ??
                  Validators.maxLength(v, 40),
            ),
            AppSpacing.vMd,
            AppTextField(
              label: FinanceStrings.labelGoalTarget,
              controller: _target,
              prefixText: '$currency ',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: AppInputFormatters.amount,
              textInputAction: TextInputAction.next,
              validator: Validators.amount,
            ),
            AppSpacing.vMd,
            AppTextField(
              label: FinanceStrings.labelGoalCurrent,
              controller: _current,
              prefixText: '$currency ',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: AppInputFormatters.amount,
              textInputAction: TextInputAction.next,
              validator: Validators.optionalAmount,
            ),
            AppSpacing.vMd,
            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.mdAll,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: FinanceStrings.labelGoalDate,
                  prefixIcon: const Icon(Icons.event_outlined),
                  errorText: _dateMissing ? FinanceStrings.dateRequired : null,
                ),
                child: Text(
                  _targetDate == null ? '' : AppDates.shortDate(_targetDate!),
                  style: t.bodyMedium,
                ),
              ),
            ),
            AppSpacing.vMd,
            AppTextField(
              label: FinanceStrings.labelGoalMonthly,
              controller: _monthly,
              prefixText: '$currency ',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: AppInputFormatters.amount,
              textInputAction: TextInputAction.done,
              validator: Validators.optionalAmount,
              helperText: 'Used to estimate when you will reach your goal.',
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
