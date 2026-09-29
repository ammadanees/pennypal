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

Future<PaymentCard?> showAddCardSheet(BuildContext context, {PaymentCard? existingCard}) {
  return showModalBottomSheet<PaymentCard>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => AddCardSheet(existingCard: existingCard),
  );
}

class AddCardSheet extends ConsumerStatefulWidget {
  const AddCardSheet({super.key, this.existingCard});

  final PaymentCard? existingCard;

  @override
  ConsumerState<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends ConsumerState<AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _bank;
  late final TextEditingController _last4;
  late String _cardType;
  late int _colorIndex;

  bool get _isEditing => widget.existingCard != null;

  static const List<String> _types = ['Debit', 'Credit', 'Prepaid'];

  static const List<(String, Color)> _themeNames = [
    ('Violet', Color(0xFF8B5CF6)),
    ('Emerald', Color(0xFF10B981)),
    ('Sunset', Color(0xFFF97316)),
    ('Sapphire', Color(0xFF2563EB)),
    ('Crimson', Color(0xFFE11D48)),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existingCard;
    _name = TextEditingController(text: e?.name ?? '');
    _bank = TextEditingController(text: e?.bank ?? '');
    _last4 = TextEditingController(text: e?.last4 ?? '');
    _cardType = e?.cardType ?? 'Debit';
    _colorIndex = e?.colorIndex ?? 0;

    _name.addListener(_onFieldChanged);
    _bank.addListener(_onFieldChanged);
    _last4.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _name.removeListener(_onFieldChanged);
    _bank.removeListener(_onFieldChanged);
    _last4.removeListener(_onFieldChanged);
    _name.dispose();
    _bank.dispose();
    _last4.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final card = PaymentCard(
      id: widget.existingCard?.id ?? IdGenerator.next(),
      name: _name.text.trim(),
      bank: _bank.text.trim().isEmpty ? null : _bank.text.trim(),
      last4: _last4.text.trim().isEmpty ? null : _last4.text.trim(),
      cardType: _cardType,
      colorIndex: _colorIndex,
      createdAt: widget.existingCard?.createdAt ?? DateTime.now(),
    );

    try {
      await ref.read(cardRepositoryProvider).save(card);
      if (!mounted) return;
      Navigator.of(context).pop(card);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Card "${card.name}" updated successfully.'
              : 'Card "${card.name}" added successfully.'),
        ),
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
    final gradient = PaymentCard.cardGradients[_colorIndex];

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
                Icon(_isEditing
                    ? Icons.edit_rounded
                    : Icons.credit_card_outlined),
                AppSpacing.hSm,
                Text(_isEditing ? 'Edit Payment Card' : 'Add New Card',
                    style: t.titleLarge),
              ],
            ),
            AppSpacing.vSm,
            Text(
              _isEditing
                  ? 'Customize your card nickname, bank, digits, and theme palette.'
                  : 'Attach up to 2 cards to use when recording income or expenses.',
              style: t.bodySmall,
            ),
            AppSpacing.vMd,

            // Live Interactive Card Mockup
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 180,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _bank.text.trim().isEmpty
                            ? 'PennyPal Student Card'
                            : _bank.text.trim().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.contactless,
                              color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _cardType.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '••••  ••••  ••••  ${_last4.text.trim().isEmpty ? '••••' : _last4.text.trim()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _name.text.trim().isEmpty
                            ? 'CARDHOLDER NAME'
                            : _name.text.trim().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      const Text(
                        'VALID THRU 12/28',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.vMd,

            // Theme Color Selection
            Text('Card Theme', style: t.labelLarge),
            AppSpacing.vXs,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < PaymentCard.cardGradients.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _colorIndex = i),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorIndex == i
                              ? _themeNames[i].$2
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: PaymentCard.cardGradients[i],
                          shape: BoxShape.circle,
                          boxShadow: _colorIndex == i
                              ? [
                                  BoxShadow(
                                    color: _themeNames[i].$2.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: _colorIndex == i
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    ),
                  ),
              ],
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
            AppButton(
              label: _isEditing ? 'Save Changes' : 'Save Card',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
