import 'package:flutter/material.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../domain/financial_health_calculator.dart';

class FinancialHealthCard extends StatelessWidget {
  const FinancialHealthCard({
    super.key,
    required this.health,
  });

  final FinancialHealthScore health;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    final (tierColor, tierIcon) = switch (health.tier) {
      HealthTier.master => (c.primary, Icons.workspace_premium),
      HealthTier.disciplined => (c.income, Icons.verified_outlined),
      HealthTier.building => (c.savings, Icons.trending_up),
      HealthTier.needsAttention => (c.expense, Icons.warning_amber_rounded),
    };

    return AppCard(
      onTap: () => _showBreakdownSheet(context),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tierColor.withOpacity(0.12),
                  border:
                      Border.all(color: tierColor.withOpacity(0.4), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${health.score}',
                      style: t.titleMedium?.copyWith(
                        color: tierColor,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '/100',
                      style: t.bodySmall?.copyWith(
                        fontSize: 9,
                        color: c.textMuted,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(tierIcon, size: 16, color: tierColor),
                        const SizedBox(width: 4),
                        Text(
                          health.tier.title,
                          style: t.labelLarge?.copyWith(
                            color: tierColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Financial Health Score',
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.info_outline, size: 18, color: c.textMuted),
            ],
          ),
          AppSpacing.vMd,
          Row(
            children: [
              Expanded(
                child: _PillarMetric(
                  label: 'Budget',
                  score: health.budgetScore,
                  max: 40,
                  color: c.primary,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: _PillarMetric(
                  label: 'Savings',
                  score: health.savingsScore,
                  max: 30,
                  color: c.income,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: _PillarMetric(
                  label: 'Habits',
                  score: health.consistencyScore,
                  max: 30,
                  color: c.savings,
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius: AppRadius.smAll,
              border: Border.all(color: c.border.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: c.primary),
                AppSpacing.hSm,
                Expanded(
                  child: Text(
                    health.recommendation,
                    style: t.bodySmall?.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Burn Rate: ${Formatters.money(health.burnRate)}/day',
                style: t.bodySmall?.copyWith(fontSize: 11, color: c.textMuted),
              ),
              Text(
                health.runwayDays >= 999
                    ? 'Runway: 30+ days'
                    : 'Runway: ${health.runwayDays} days left',
                style: t.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: health.runwayDays < 10 && health.runwayDays > 0
                      ? c.expense
                      : c.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBreakdownSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final c = ctx.colors;
        final t = ctx.text;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Financial Health Index',
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                AppSpacing.vXs,
                Text(
                  'Your score measures spending discipline, savings margin, and habit consistency to help you graduate debt-free.',
                  style: t.bodySmall,
                ),
                AppSpacing.vMd,
                _ScoreDetailRow(
                  title: 'Budget Discipline (40 pts)',
                  description:
                      'Evaluates whether your spending is pacing below or above your monthly budget.',
                  points: '${health.budgetScore} / 40',
                  color: c.primary,
                ),
                AppSpacing.vSm,
                _ScoreDetailRow(
                  title: 'Savings Margin (30 pts)',
                  description:
                      'Measures the percentage of monthly income retained after all expenses.',
                  points: '${health.savingsScore} / 30',
                  color: c.income,
                ),
                AppSpacing.vSm,
                _ScoreDetailRow(
                  title: 'Habit Consistency (30 pts)',
                  description:
                      'Rewards daily transaction logging and active savings goal contributions.',
                  points: '${health.consistencyScore} / 30',
                  color: c.savings,
                ),
                AppSpacing.vLg,
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: c.surfaceElevated,
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(color: c.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              size: 18, color: c.primary),
                          AppSpacing.hSm,
                          Text(
                            'AI Smart Coach Tip',
                            style: t.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: c.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(health.recommendation, style: t.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PillarMetric extends StatelessWidget {
  const _PillarMetric({
    required this.label,
    required this.score,
    required this.max,
    required this.color,
  });

  final String label;
  final int score;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final progress = (score / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: t.bodySmall?.copyWith(fontSize: 10, color: c.textMuted)),
            Text('$score/$max',
                style: t.bodySmall
                    ?.copyWith(fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: AppRadius.pillAll,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: c.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _ScoreDetailRow extends StatelessWidget {
  const _ScoreDetailRow({
    required this.title,
    required this.description,
    required this.points,
    required this.color,
  });

  final String title;
  final String description;
  final String points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        t.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(description,
                    style: t.bodySmall?.copyWith(color: c.textSecondary)),
              ],
            ),
          ),
          AppSpacing.hSm,
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              points,
              style: t.labelSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
