import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/finance_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../data/savings_repository.dart';
import '../domain/savings_goal.dart';

Future<void> showContributeSheet(BuildContext context, SavingsGoal goal) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => ContributeSheet(goal: goal),
  );
}

/// Adds money to a goal. Reaching the target completes and archives it.
class ContributeSheet extends ConsumerStatefulWidget {
  const ContributeSheet({super.key, required this.goal});

  final SavingsGoal goal;

  @override
  ConsumerState<ContributeSheet> createState() => _ContributeSheetState();
}

class _ContributeSheetState extends ConsumerState<ContributeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.goal.monthlyContribution > 0
        ? (widget.goal.monthlyContribution % 1 == 0
            ? widget.goal.monthlyContribution.toInt().toString()
            : widget.goal.monthlyContribution.toString())
        : '',
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final goal = widget.goal;
    final updated =
        goal.withSaved(goal.currentAmount + double.parse(_amount.text.trim()));
    await ref.read(savingsRepositoryProvider).save(updated);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated.isCompleted
              ? FinanceStrings.goalReached(goal.name)
              : FinanceStrings.contributeSaved,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(FinanceStrings.contributeTitle, style: context.text.titleLarge),
            Text(widget.goal.name, style: context.text.bodySmall),
            AppSpacing.vMd,
            AppTextField(
              label: FinanceStrings.labelAmount,
              controller: _amount,
              prefixText: 'Rs. ',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: AppInputFormatters.amount,
              validator: Validators.amount,
              onSubmitted: (_) => _save(),
            ),
            AppSpacing.vLg,
            AppButton(label: FinanceStrings.addMoney, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
