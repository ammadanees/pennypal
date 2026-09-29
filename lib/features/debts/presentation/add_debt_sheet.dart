import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../data/debt_repository.dart';
import '../domain/debt_record.dart';

Future<DebtRecord?> showAddDebtSheet(
  BuildContext context, {
  DebtRecord? existing,
}) {
  return showModalBottomSheet<DebtRecord>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => AddDebtSheet(existing: existing),
  );
}

class AddDebtSheet extends ConsumerStatefulWidget {
  const AddDebtSheet({super.key, this.existing});

  final DebtRecord? existing;

  @override
  ConsumerState<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends ConsumerState<AddDebtSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late DebtType _type;
  DateTime? _dueDate;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.personName ?? '');
    _amount = TextEditingController(
      text: e != null
          ? (e.amount % 1 == 0
              ? e.amount.toInt().toString()
              : e.amount.toString())
          : '',
    );
    _note = TextEditingController(text: e?.note ?? '');
    _type = e?.type ?? DebtType.lent;
    _dueDate = e?.dueDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final debt = DebtRecord(
      id: widget.existing?.id ?? IdGenerator.next(),
      personName: _name.text.trim(),
      amount: double.parse(_amount.text.trim()),
      type: _type,
      note: _note.text.trim(),
      dueDate: _dueDate,
      isSettled: widget.existing?.isSettled ?? false,
      settledAt: widget.existing?.settledAt,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    await ref.read(debtRepositoryProvider).save(debt);
    if (!mounted) return;
    Navigator.of(context).pop(debt);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Updated debt record for ${debt.personName}'
              : 'Recorded ${_type == DebtType.lent ? "lent amount to" : "borrowed from"} ${debt.personName}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final currency = ref.watch(currencyProvider);

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
            Row(
              children: [
                Icon(
                  _type == DebtType.lent
                      ? Icons.arrow_outward_rounded
                      : Icons.arrow_downward_rounded,
                  color: _type == DebtType.lent ? c.income : c.expense,
                ),
                AppSpacing.hSm,
                Text(
                  _isEditing ? 'Edit Record' : 'Record Lent / Borrowed Money',
                  style: t.titleLarge,
                ),
              ],
            ),
            AppSpacing.vSm,
            Text(
              'Keep track of small student loans, group meals, and cash shared with friends.',
              style: t.bodySmall,
            ),
            AppSpacing.vMd,

            // Segmented Type Selector
            SegmentedButton<DebtType>(
              segments: const [
                ButtonSegment(
                  value: DebtType.lent,
                  label: Text('I Lent (They Owe Me)'),
                  icon: Icon(Icons.call_made_rounded),
                ),
                ButtonSegment(
                  value: DebtType.borrowed,
                  label: Text('I Borrowed (I Owe)'),
                  icon: Icon(Icons.call_received_rounded),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _type = val.first);
              },
            ),
            AppSpacing.vMd,

            AppTextField(
              label: 'Person / Friend Name',
              hint: 'e.g. Sara, Alex, Roommate Ali',
              controller: _name,
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, 'person name'),
            ),
            AppSpacing.vMd,
            AppTextField(
              label: 'Amount',
              controller: _amount,
              prefixText: '$currency ',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: AppInputFormatters.amount,
              textInputAction: TextInputAction.next,
              validator: Validators.amount,
            ),
            AppSpacing.vMd,
            AppTextField(
              label: 'Reason / Note (optional)',
              hint: 'e.g. Lunch split, Semester notes print, Uber ride',
              controller: _note,
              prefixIcon: Icons.notes_outlined,
              textInputAction: TextInputAction.done,
            ),
            AppSpacing.vMd,

            // Optional Due Date
            InkWell(
              onTap: _pickDueDate,
              borderRadius: AppRadius.mdAll,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Expected Return Date (optional)',
                  prefixIcon: const Icon(Icons.event_outlined),
                  suffixIcon: _dueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _dueDate = null),
                        )
                      : null,
                ),
                child: Text(
                  _dueDate == null
                      ? 'No due date set'
                      : AppDates.shortDate(_dueDate!),
                  style: t.bodyMedium?.copyWith(
                    color: _dueDate == null ? c.textMuted : c.textPrimary,
                  ),
                ),
              ),
            ),
            AppSpacing.vLg,
            AppButton(
              label: _isEditing ? 'Save Changes' : 'Save Record',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
