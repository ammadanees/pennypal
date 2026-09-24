import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_durations.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';

/// Progress toward a savings goal, in the savings colour.
class SavingsProgress extends StatelessWidget {
  const SavingsProgress({
    super.key,
    required this.current,
    required this.target,
    this.label,
  });

  final double current;
  final double target;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ratio = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    return Semantics(
      label: '${label ?? 'Savings'}: ${Formatters.money(current)} of '
          '${Formatters.money(target)}, ${Formatters.percent(ratio)} saved.',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label ?? '',
                  style: context.text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(Formatters.percent(ratio), style: context.text.labelLarge),
            ],
          ),
          AppSpacing.vSm,
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: AppDurations.normal,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: AppDimensions.progressHeight,
                color: c.savings,
                backgroundColor: c.border,
              ),
            ),
          ),
          AppSpacing.vXs,
          Text(
            '${Formatters.money(current)} of ${Formatters.money(target)}',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}
