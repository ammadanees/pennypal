import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_durations.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class MonthBar {
  const MonthBar({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final double value;
  final bool highlighted;
}

/// Simple vertical bars with value labels above and month labels below.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.bars,
    required this.color,
    required this.semanticLabel,
    this.barAreaHeight = 140,
  });

  final List<MonthBar> bars;
  final Color color;
  final String semanticLabel;
  final double barAreaHeight;

  static const double _labelRow = 20;

  @override
  Widget build(BuildContext context) {
    final maxValue = bars.fold<double>(0, (m, b) => math.max(m, b.value));
    final c = context.colors;

    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: barAreaHeight + _labelRow * 2 + AppSpacing.sm,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final bar in bars)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: _labelRow,
                        child: Text(
                          Formatters.compact(bar.value),
                          style: context.text.labelSmall?.copyWith(
                            color: bar.highlighted ? c.textPrimary : c.textSecondary,
                          ),
                        ),
                      ),
                      AppSpacing.vXs,
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: maxValue <= 0 ? 0 : bar.value / maxValue,
                        ),
                        duration: AppDurations.slow,
                        curve: Curves.easeOutCubic,
                        builder: (_, fraction, __) => Container(
                          height: math.max(2.0, barAreaHeight * fraction),
                          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: bar.value <= 0
                                ? c.border
                                : (bar.highlighted ? color : color.withOpacity(0.4)),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.sm),
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.vXs,
                      SizedBox(
                        height: _labelRow,
                        child: Text(
                          bar.label,
                          style: context.text.labelSmall?.copyWith(
                            color: bar.highlighted ? c.textPrimary : c.textSecondary,
                            fontWeight:
                                bar.highlighted ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
