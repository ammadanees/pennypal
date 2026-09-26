import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/constants/finance_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/image_upload_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../data/transaction_repository.dart';
import '../domain/finance_transaction.dart';
import '../../cards/presentation/card_selector_view.dart';

/// Add or edit an income or expense. Works fully offline.
class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({
    super.key,
    this.initialType = TransactionType.expense,
    this.existing,
  });

  final TransactionType initialType;
  final FinanceTransaction? existing;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  late DateTime _date;
  late final TextEditingController _amount;
  late final TextEditingController _source;
  late final TextEditingController _description;
  ExpenseCategory? _category;
  PaymentMode _mode = PaymentMode.cash;
  String? _selectedCardId;
  String? _selectedCardName;
  bool _categoryMissing = false;
  String? _receiptUrl;

  bool get _isEditing => widget.existing != null;
  bool get _isIncome => _type == TransactionType.income;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? widget.initialType;
    _date = e?.date ?? DateTime.now();
    _category = e?.category;
    _mode = e?.paymentMode ?? PaymentMode.cash;
    _selectedCardId = e?.cardId;
    _selectedCardName = e?.cardName;
    _receiptUrl = e?.receiptImageUrl;
    _amount = TextEditingController(
      text: e == null
          ? ''
          : (e.amount % 1 == 0 ? e.amount.toInt().toString() : e.amount.toString()),
    );
    _source = TextEditingController(text: e?.source ?? '');
    _description = TextEditingController(text: e?.description ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _source.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isIncome && _category == null) {
      setState(() => _categoryMissing = true);
      return;
    }
    final existing = widget.existing;
    final transaction = FinanceTransaction(
      id: existing?.id ?? IdGenerator.next(),
      type: _type,
      amount: double.parse(_amount.text.trim()),
      date: _date,
      createdAt: existing?.createdAt ?? DateTime.now(),
      category: _isIncome ? null : _category,
      paymentMode: _mode,
      cardId: _mode == PaymentMode.card ? _selectedCardId : null,
      cardName: _mode == PaymentMode.card ? _selectedCardName : null,
      source: _isIncome ? _source.text.trim() : null,
      description: _description.text.trim(),
      receiptImageUrl: _isIncome ? null : _receiptUrl,
    );
    await ref.read(transactionRepositoryProvider).save(transaction);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(FinanceStrings.transactionSaved)),
    );
    context.pop();
  }

  Future<void> _delete() async {
    final ok = await confirmAction(
      context,
      title: FinanceStrings.deleteTransactionTitle,
      message: FinanceStrings.deleteMessage,
      confirmLabel: FinanceStrings.delete,
    );
    if (!ok || !mounted) return;
    await ref.read(transactionRepositoryProvider).delete(widget.existing!.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(FinanceStrings.transactionDeleted)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final title = _isEditing
        ? (_isIncome ? FinanceStrings.editIncome : FinanceStrings.editExpense)
        : (_isIncome ? FinanceStrings.newIncome : FinanceStrings.newExpense);

    return AppScaffold(
      title: title,
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
            if (!_isEditing) ...[
              SegmentedButton<TransactionType>(
                expandedInsets: EdgeInsets.zero,
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(FinanceStrings.filterExpense),
                    icon: Icon(Icons.north_east),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(FinanceStrings.filterIncome),
                    icon: Icon(Icons.south_west),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              AppSpacing.vMd,
            ],
            AppTextField(
              label: FinanceStrings.labelAmount,
              controller: _amount,
              prefixText: 'Rs. ',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: AppInputFormatters.amount,
              textInputAction: TextInputAction.next,
              validator: Validators.amount,
            ),
            AppSpacing.vMd,
            if (_isIncome) ...[
              AppTextField(
                label: FinanceStrings.labelSource,
                controller: _source,
                prefixIcon: Icons.work_outline,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, 'income source'),
              ),
              AppSpacing.vSm,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final s in incomeSourceSuggestions)
                    AppChip(
                      label: s,
                      selected: _source.text.trim() == s,
                      onSelected: () => setState(() => _source.text = s),
                    ),
                ],
              ),
            ] else ...[
              Text(FinanceStrings.labelCategory, style: t.labelLarge),
              AppSpacing.vSm,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final cat in ExpenseCategory.values)
                    AppChip(
                      label: cat.label,
                      icon: cat.icon,
                      selected: _category == cat,
                      onSelected: () => setState(() {
                        _category = cat;
                        _categoryMissing = false;
                      }),
                    ),
                ],
              ),
              if (_categoryMissing) ...[
                AppSpacing.vXs,
                Text(
                  FinanceStrings.categoryRequired,
                  style: t.bodySmall?.copyWith(color: c.error),
                ),
              ],
            ],
            AppSpacing.vMd,
            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.mdAll,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: FinanceStrings.labelDate,
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Text(
                  '${Formatters.dayLabel(_date)}, ${Formatters.time(_date)}',
                  style: t.bodyMedium,
                ),
              ),
            ),
            AppSpacing.vMd,
            AppTextField(
              label: FinanceStrings.labelDescription,
              controller: _description,
              prefixIcon: Icons.notes_outlined,
              maxLines: 2,
              validator: (v) => Validators.maxLength(v, 100),
            ),
            AppSpacing.vMd,
            Text(
              _isIncome ? 'Payment received via' : FinanceStrings.labelPaidWith,
              style: t.labelLarge,
            ),
            AppSpacing.vSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final m in PaymentMode.values)
                  AppChip(
                    label: m.label,
                    icon: m.icon,
                    selected: _mode == m,
                    onSelected: () => setState(() => _mode = m),
                  ),
              ],
            ),
            if (_mode == PaymentMode.card) ...[
              AppSpacing.vMd,
              CardSelectorView(
                selectedCardId: _selectedCardId,
                onCardSelected: (card) {
                  setState(() {
                    _selectedCardId = card?.id;
                    _selectedCardName = card?.displayName;
                  });
                },
              ),
            ],
            AppSpacing.vXs,
            Text(FinanceStrings.paymentNote, style: t.bodySmall),
            if (!_isIncome) ...[
              AppSpacing.vMd,
              Text(FinanceStrings.labelReceipt, style: t.labelLarge),
              AppSpacing.vSm,
              if (_receiptUrl != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.mdAll,
                      child: Image.network(
                        _receiptUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: c.surfaceElevated,
                          alignment: Alignment.center,
                          child: Icon(Icons.broken_image_outlined, color: c.textMuted),
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Material(
                        color: c.surface,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Remove photo',
                          onPressed: () => setState(() => _receiptUrl = null),
                        ),
                      ),
                    ),
                  ],
                )
              else
                ImageUploadButton(
                  label: FinanceStrings.addReceipt,
                  onUploaded: (url) => setState(() => _receiptUrl = url),
                ),
            ],
            AppSpacing.vLg,
            AppButton(label: FinanceStrings.save, onPressed: _save),
            AppSpacing.vLg,
          ],
        ),
      ),
    );
  }
}
