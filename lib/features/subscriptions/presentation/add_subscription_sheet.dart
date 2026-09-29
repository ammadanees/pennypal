import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_record.dart';

Future<SubscriptionRecord?> showAddSubscriptionSheet(
  BuildContext context, {
  SubscriptionRecord? existing,
}) {
  return showModalBottomSheet<SubscriptionRecord>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => AddSubscriptionSheet(existing: existing),
  );
}

class AddSubscriptionSheet extends ConsumerStatefulWidget {
  const AddSubscriptionSheet({super.key, this.existing});

  final SubscriptionRecord? existing;

  @override
  ConsumerState<AddSubscriptionSheet> createState() =>
      _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends ConsumerState<AddSubscriptionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late int _dueDay;
  late ExpenseCategory _category;
  String _billingCycle = 'monthly';
  bool _reminder = true;

  bool get _isEditing => widget.existing != null;

  static const List<(String, double, ExpenseCategory)> _studentTemplates = [
    ('Spotify Student', 299, ExpenseCategory.entertainment),
    ('Netflix Student', 800, ExpenseCategory.entertainment),
    ('Hostel Rent', 15000, ExpenseCategory.bills),
    ('Campus Bus Pass', 3500, ExpenseCategory.transport),
    ('Mobile Data 4G', 1200, ExpenseCategory.bills),
    ('Gym Student Pass', 2500, ExpenseCategory.miscellaneous),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _amount = TextEditingController(
      text: e != null
          ? (e.amount % 1 == 0
              ? e.amount.toInt().toString()
              : e.amount.toString())
          : '',
    );
    _dueDay = e?.dueDay ?? 1;
    _category = e?.category ?? ExpenseCategory.entertainment;
    _billingCycle = e?.billingCycle ?? 'monthly';
    _reminder = e?.reminderEnabled ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _applyTemplate(String name, double amount, ExpenseCategory category) {
    HapticFeedback.selectionClick();
    setState(() {
      _name.text = name;
      _amount.text =
          amount % 1 == 0 ? amount.toInt().toString() : amount.toString();
      _category = category;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final sub = SubscriptionRecord(
      id: widget.existing?.id ?? IdGenerator.next(),
      name: _name.text.trim(),
      amount: double.parse(_amount.text.trim()),
      billingCycle: _billingCycle,
      dueDay: _dueDay,
      category: _category,
      reminderEnabled: _reminder,
      lastPaidDate: widget.existing?.lastPaidDate,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    await ref.read(subscriptionRepositoryProvider).save(sub);
    if (!mounted) return;
    Navigator.of(context).pop(sub);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Updated subscription "${sub.name}"'
              : 'Added subscription "${sub.name}"',
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
                const Icon(Icons.repeat_rounded),
                AppSpacing.hSm,
                Text(
                  _isEditing ? 'Edit Subscription' : 'Add Subscription / Bill',
                  style: t.titleLarge,
                ),
              ],
            ),
            AppSpacing.vSm,
            Text(
              'Track recurring student expenses so you never miss a payment.',
              style: t.bodySmall,
            ),
            AppSpacing.vMd,

            // Quick Student Templates
            if (!_isEditing) ...[
              Text('Quick Student Presets', style: t.labelMedium),
              AppSpacing.vXs,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (name, amt, cat) in _studentTemplates)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ActionChip(
                          avatar: Icon(cat.icon, size: 14),
                          label: Text(name),
                          onPressed: () => _applyTemplate(name, amt, cat),
                        ),
                      ),
                  ],
                ),
              ),
              AppSpacing.vMd,
            ],

            AppTextField(
              label: 'Subscription / Bill Name',
              hint: 'e.g. Spotify, Hostel Rent, Metro Card',
              controller: _name,
              prefixIcon: Icons.subscriptions_outlined,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, 'name'),
            ),
            AppSpacing.vMd,
            AppTextField(
              label: 'Amount per Cycle',
              controller: _amount,
              prefixText: '$currency ',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: AppInputFormatters.amount,
              textInputAction: TextInputAction.next,
              validator: Validators.amount,
            ),
            AppSpacing.vMd,

            // Due Day Slider / Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Billing Day of Month', style: t.labelLarge),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Text(
                    'Day $_dueDay of each month',
                    style: t.labelSmall?.copyWith(
                      color: c.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _dueDay.toDouble(),
              min: 1,
              max: 31,
              divisions: 30,
              label: 'Day $_dueDay',
              onChanged: (val) => setState(() => _dueDay = val.round()),
            ),
            AppSpacing.vSm,

            // Category Chips
            Text('Category', style: t.labelLarge),
            AppSpacing.vXs,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final cat in ExpenseCategory.values)
                  AppChip(
                    label: cat.label,
                    icon: cat.icon,
                    selected: _category == cat,
                    onSelected: () => setState(() => _category = cat),
                  ),
              ],
            ),
            AppSpacing.vLg,
            AppButton(
              label: _isEditing ? 'Save Changes' : 'Add Subscription',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
