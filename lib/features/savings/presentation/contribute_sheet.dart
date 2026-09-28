import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/finance_strings.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/data/auth_providers.dart';
import '../data/savings_repository.dart';
import '../domain/savings_calculator.dart';
import '../domain/savings_goal.dart';

Future<void> showContributeSheet(BuildContext context, SavingsGoal goal) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => ContributeSheet(goal: goal),
  );
}

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
    final oldProgress = SavingsCalculator.progress(goal);
    final updated =
        goal.withSaved(goal.currentAmount + double.parse(_amount.text.trim()));
    final newProgress = SavingsCalculator.progress(updated);
    await ref.read(savingsRepositoryProvider).save(updated);

    final user = ref.read(authStateProvider).valueOrNull;
    if (user?.notificationsEnabled ?? true) {
      if (updated.isCompleted && !goal.isCompleted) {
        await LocalNotificationService.showSavingsMilestone(
          goalName: goal.name,
          milestone: 100,
        );
      } else {
        final newlyReached = newProgress.milestonesReached
            .toSet()
            .difference(oldProgress.milestonesReached.toSet());
        if (newlyReached.isNotEmpty) {
          await LocalNotificationService.showSavingsMilestone(
            goalName: goal.name,
            milestone: newlyReached.last,
          );
        }
      }
    }

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
        AppSpacing.lg +
            MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(FinanceStrings.contributeTitle,
                style: context.text.titleLarge),
            Text(widget.goal.name, style: context.text.bodySmall),
            AppSpacing.vMd,
            AppTextField(
              label: FinanceStrings.labelAmount,
              controller: _amount,
              prefixText: 'Rs. ',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
