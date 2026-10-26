import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/currency_exchange_service.dart';
import '../../../core/services/currency_migration_service.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class CurrencySwitchSheet extends ConsumerStatefulWidget {
  const CurrencySwitchSheet({
    super.key,
    required this.oldOption,
    required this.newOption,
  });

  final CurrencyOption oldOption;
  final CurrencyOption newOption;

  static Future<void> show(
    BuildContext context, {
    required CurrencyOption oldOption,
    required CurrencyOption newOption,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => CurrencySwitchSheet(
        oldOption: oldOption,
        newOption: newOption,
      ),
    );
  }

  @override
  ConsumerState<CurrencySwitchSheet> createState() =>
      _CurrencySwitchSheetState();
}

class _CurrencySwitchSheetState extends ConsumerState<CurrencySwitchSheet> {
  CurrencySwitchMode _mode = CurrencySwitchMode.convertAll;
  double _rate = 1.0;
  bool _isLiveRate = false;
  bool _isLoadingRate = true;
  String? _rateError;
  bool _isMigrating = false;
  String _statusMessage = '';

  bool _isEditingRate = false;
  final _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRate();
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _loadRate() async {
    setState(() {
      _isLoadingRate = true;
      _rateError = null;
    });

    final service = ref.read(currencyExchangeServiceProvider);
    final result = await service.fetchRate(
      fromCode: widget.oldOption.code,
      toCode: widget.newOption.code,
    );

    if (!mounted) return;
    setState(() {
      _rate = result.rate;
      _isLiveRate = result.isLive;
      _rateError = result.error;
      _isLoadingRate = false;
      _rateController.text = _rate.toStringAsFixed(4);
    });
  }

  Future<void> _applySwitch() async {
    setState(() {
      _isMigrating = true;
      _statusMessage = 'Preparing currency update...';
    });

    try {
      final migration = ref.read(currencyMigrationServiceProvider);
      await migration.executeSwitch(
        mode: _mode,
        oldSymbol: widget.oldOption.symbol,
        newSymbol: widget.newOption.symbol,
        exchangeRate: _rate,
        onProgress: (msg) {
          if (mounted) setState(() => _statusMessage = msg);
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Currency switched to ${widget.newOption.name} (${widget.newOption.symbol})',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isMigrating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating currency: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    const previewOld = 1000.0;
    final previewNew = previewOld * _rate;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title & Switch visual
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Switch Currency', style: t.titleLarge),
                      AppSpacing.vXs,
                      Text(
                        'Choose how your financial data should adapt',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
                _CurrencyBadge(option: widget.oldOption),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 20, color: c.textMuted),
                ),
                _CurrencyBadge(option: widget.newOption, isNew: true),
              ],
            ),
            AppSpacing.vMd,

            // Exchange Rate Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: c.surfaceElevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 20, color: c.primary),
                      AppSpacing.hSm,
                      Text(
                        'Exchange Rate',
                        style: t.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (_isLoadingRate)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _isLiveRate
                                ? c.income.withValues(alpha: 0.15)
                                : c.warning.withValues(alpha: 0.15),
                            borderRadius: AppRadius.smAll,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor:
                                    _isLiveRate ? c.income : c.warning,
                              ),
                              AppSpacing.hXs,
                              Text(
                                _isLiveRate ? 'Live' : 'Estimate',
                                style: t.bodySmall?.copyWith(
                                  color: _isLiveRate ? c.income : c.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          tooltip: _rateError ?? 'Refresh rate',
                          visualDensity: VisualDensity.compact,
                          onPressed: _loadRate,
                        ),
                      ],
                    ],
                  ),
                  AppSpacing.vSm,
                  if (_isEditingRate) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _rateController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              labelText:
                                  '1 ${widget.oldOption.code} in ${widget.newOption.code}',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.hSm,
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            final parsed =
                                double.tryParse(_rateController.text.trim());
                            if (parsed != null && parsed > 0) {
                              setState(() {
                                _rate = parsed;
                                _isEditingRate = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ] else ...[
                    InkWell(
                      onTap: () => setState(() => _isEditingRate = true),
                      child: Row(
                        children: [
                          Text(
                            '1 ${widget.oldOption.code} = ${_rate.toStringAsPrecision(4)} ${widget.newOption.code}',
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: c.primary,
                            ),
                          ),
                          AppSpacing.hSm,
                          Icon(Icons.edit_outlined, size: 15, color: c.textMuted),
                        ],
                      ),
                    ),
                  ],
                  AppSpacing.vXs,
                  Text(
                    'Preview: ${widget.oldOption.symbol} 1,000 ≈ ${widget.newOption.symbol} ${previewNew.toStringAsFixed(2)}',
                    style: t.bodySmall?.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
            AppSpacing.vMd,

            Text(
              'Select Migration Option',
              style: t.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vSm,

            // Option 1: Convert All Existing Records
            _OptionCard(
              title: 'Convert All Existing Records',
              subtitle:
                  'Recalculates all past transactions, budgets, goals, debts, and subscriptions using the rate so charts and totals stay accurate.',
              badge: 'Recommended',
              icon: Icons.currency_exchange,
              isSelected: _mode == CurrencySwitchMode.convertAll,
              onTap: () => setState(() => _mode = CurrencySwitchMode.convertAll),
            ),
            AppSpacing.vSm,

            // Option 2: Apply to New Records Only
            _OptionCard(
              title: 'Apply to New Records Only',
              subtitle:
                  'Past records permanently keep their ${widget.oldOption.symbol} tag. Future records will be logged in ${widget.newOption.symbol}.',
              icon: Icons.history_toggle_off,
              isSelected: _mode == CurrencySwitchMode.newRecordsOnly,
              onTap: () =>
                  setState(() => _mode = CurrencySwitchMode.newRecordsOnly),
            ),
            AppSpacing.vSm,

            // Option 3: Change Display Symbol Only
            _OptionCard(
              title: 'Change Display Symbol Only',
              subtitle:
                  'Keep all numbers untouched, only display the new symbol (${widget.newOption.symbol}). Best for fixing onboarding typos.',
              icon: Icons.label_outline,
              isSelected: _mode == CurrencySwitchMode.symbolOnly,
              onTap: () => setState(() => _mode = CurrencySwitchMode.symbolOnly),
            ),
            AppSpacing.vLg,

            if (_isMigrating && _statusMessage.isNotEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      AppSpacing.hSm,
                      Text(_statusMessage, style: t.bodySmall),
                    ],
                  ),
                ),
              ),
            ],

            // Actions
            AppButton(
              label: 'Apply Currency Switch',
              icon: Icons.check,
              isLoading: _isMigrating,
              onPressed: _isMigrating ? null : _applySwitch,
            ),
            AppSpacing.vXs,
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.text,
              onPressed: _isMigrating ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyBadge extends StatelessWidget {
  const _CurrencyBadge({required this.option, this.isNew = false});

  final CurrencyOption option;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isNew ? c.primarySoft : c.surfaceElevated,
        borderRadius: AppRadius.smAll,
        border: Border.all(
          color: isNew ? c.primary : c.border,
          width: isNew ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            option.symbol,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isNew ? c.primary : c.textPrimary,
            ),
          ),
          Text(
            option.code,
            style: t.bodySmall?.copyWith(fontSize: 10, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? c.primarySoft.withValues(alpha: 0.25)
              : c.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: isSelected ? c.primary : c.border,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? c.primary : c.textMuted,
                size: 20,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: isSelected ? c.primary : c.textMuted),
                      AppSpacing.hXs,
                      Expanded(
                        child: Text(
                          title,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? c.primary : c.textPrimary,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: c.primary,
                            borderRadius: AppRadius.smAll,
                          ),
                          child: Text(
                            badge!,
                            style: t.bodySmall?.copyWith(
                              color: c.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppSpacing.vXs,
                  Text(
                    subtitle,
                    style: t.bodySmall?.copyWith(
                      color: c.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
