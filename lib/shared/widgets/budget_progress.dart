import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_durations.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';

class BudgetProgress extends StatelessWidget {
  const BudgetProgress({
    super.key,
    required this.label,
    required this.spent,
    required this.limit,
    this.alertThreshold = 0.8,
  });

  final String label;
  final double spent;
  final double limit;
  final double alertThreshold;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ratio = limit <= 0 ? 0.0 : spent / limit;

    final (Color color, IconData icon, String status) = ratio >= 1
        ? (c.error, Icons.error_outline, AppStrings.budgetOver)
        : ratio >= alertThreshold
            ? (
                c.warning,
                Icons.warning_amber_outlined,
                AppStrings.budgetNearing
              )
            : (c.success, Icons.check_circle_outline, AppStrings.budgetOnTrack);

    return Semantics(
      label:
          '$label: ${Formatters.money(spent)} of ${Formatters.money(limit)}, '
          '${Formatters.percent(ratio)} used. $status.',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: context.text.titleMedium)),
              Text(Formatters.percent(ratio), style: context.text.labelLarge),
            ],
          ),
          AppSpacing.vSm,
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
              duration: AppDurations.normal,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: AppDimensions.progressHeight,
                color: color,
                backgroundColor: c.border,
              ),
            ),
          ),
          AppSpacing.vXs,
          Row(
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: color),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  '${Formatters.money(spent)} of ${Formatters.money(limit)}',
                  style: context.text.bodySmall,
                ),
              ),
              Text(status,
                  style: context.text.bodySmall?.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
