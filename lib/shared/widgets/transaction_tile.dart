import 'package:flutter/material.dart';

import '../../core/theme/app_accents.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'accent_icon_box.dart';
import 'money_display.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.kind,
    required this.icon,
    this.currency,
    this.accent,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final double amount;
  final MoneyKind kind;
  final IconData icon;
  final String? currency;

  final AppAccent? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final resolved = accent ??
        AppAccent(kind == MoneyKind.income ? c.income : c.expense, c.onPrimary);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: AppDimensions.touchTarget),
          child: Row(
            children: [
              AccentIconBox(icon: icon, accent: resolved),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall),
                  ],
                ),
              ),
              AppSpacing.hSm,
              MoneyDisplay(
                amount: amount,
                size: MoneySize.body,
                kind: kind,
                currency: currency,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
