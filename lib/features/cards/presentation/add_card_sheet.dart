import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../data/card_repository.dart';
import '../domain/payment_card.dart';

Future<PaymentCard?> showAddCardSheet(BuildContext context) {
  return showModalBottomSheet<PaymentCard>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => const AddCardSheet(),
  );
}

class AddCardSheet extends ConsumerStatefulWidget {
  const AddCardSheet({super.key});

  @override
  ConsumerState<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends ConsumerState<AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _bank = TextEditingController();
  final _last4 = TextEditingController();
  String _cardType = 'Debit';
  final int _colorIndex = 0;

  static const List<String> _types = ['Debit', 'Credit', 'Prepaid'];

  @override
  void dispose() {
    _name.dispose();
    _bank.dispose();
    _last4.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final card = PaymentCard(
      id: IdGenerator.next(),
      name: _name.text.trim(),
      bank: _bank.text.trim().isEmpty ? null : _bank.text.trim(),
      last4: _last4.text.trim().isEmpty ? null : _last4.text.trim(),
      cardType: _cardType,
      colorIndex: _colorIndex,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(cardRepositoryProvider).save(card);
      if (!mounted) return;
      Navigator.of(context).pop(card);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card "${card.name}" added successfully.')),
      );
    } on CardLimitExceededException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: context.colors.expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.text;

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
                const Icon(Icons.credit_card_outlined),
                AppSpacing.hSm,
                Text('Add New Card', style: t.titleLarge),
              ],
            ),
            AppSpacing.vSm,
            Text(
              'Attach up to 2 cards to use when recording income or expenses.',
              style: t.bodySmall,
            ),
            AppSpacing.vMd,
            AppTextField(
              label: 'Card name / Nickname',
              hint: 'e.g. Meezan Visa, SadaPay, HBL Debit',
              controller: _name,
              prefixIcon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, 'Card name'),
            ),
            AppSpacing.vMd,
            AppTextField(
              label: 'Bank name (optional)',
              hint: 'e.g. Meezan Bank, Standard Chartered',
              controller: _bank,
              prefixIcon: Icons.account_balance_outlined,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.maxLength(v, 40),
            ),
            AppSpacing.vMd,
            AppTextField(
              label: 'Last 4 digits (optional)',
              hint: 'e.g. 4128',
              controller: _last4,
              prefixIcon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (v.trim().length != 4) return 'Enter exactly 4 digits';
                return null;
              },
            ),
            AppSpacing.vMd,
            Text('Card type', style: t.labelLarge),
            AppSpacing.vXs,
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final type in _types)
                  AppChip(
                    label: type,
                    selected: _cardType == type,
                    onSelected: () => setState(() => _cardType = type),
                  ),
              ],
            ),
            AppSpacing.vLg,
            AppButton(label: 'Save Card', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
