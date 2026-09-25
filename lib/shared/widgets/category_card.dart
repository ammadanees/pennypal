import 'package:flutter/material.dart';

import '../../core/constants/app_categories.dart';
import '../../core/theme/app_accents.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';

/// Solid, vivid card for one spending category: how much was spent, its
/// share of all spending, and how much of its limit is used.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.spent,
    required this.shareOfSpend,
    this.limit,
    this.alertThreshold = 0.8,
  });

  final ExpenseCategory category;
  final double spent;
  final double shareOfSpend;
  final double? limit;
  final double alertThreshold;

  @override
  Widget build(BuildContext context) {
    final accent = AppAccents.forCategory(category);
    final fg = accent.onColor;
    final t = context.text;
    final ratio = (limit == null || limit! <= 0) ? null : spent / limit!;
    final badge = ratio == null
        ? null
        : ratio > 1
            ? 'OVER'
            : ratio == 1
                ? 'MAXED'
                : ratio >= alertThreshold
                    ? 'NEARING'
                    : null;
    final detail = '${Formatters.percent(shareOfSpend)} of spend'
        '${ratio == null ? '' : ' \u00b7 ${Formatters.percent(ratio)} of limit'}';

    return Semantics(
      label: '${category.label}: ${Formatters.money(spent)}. $detail.'
          '${limit == null ? '' : ' Limit ${Formatters.money(limit!)}.'}'
          '${badge == null ? '' : ' $badge.'}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: accent.color, borderRadius: AppRadius.xlAll),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: fg.withOpacity(0.2),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Icon(category.icon, color: fg),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              category.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.titleMedium?.copyWith(color: fg),
                            ),
                          ),
                          if (badge != null) ...[
                            AppSpacing.hSm,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: fg.withOpacity(0.22),
                                borderRadius: AppRadius.pillAll,
                              ),
                              child: Text(
                                badge,
                                style: t.labelSmall?.copyWith(
                                  color: fg,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        detail,
                        style: t.bodySmall?.copyWith(color: fg.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hSm,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.money(spent),
                      style: t.titleLarge?.copyWith(color: fg),
                    ),
                    if (limit != null)
                      Text(
                        'of ${Formatters.money(limit!)}',
                        style: t.bodySmall?.copyWith(color: fg.withOpacity(0.9)),
                      ),
                  ],
                ),
              ],
            ),
            if (ratio != null) ...[
              AppSpacing.vMd,
              ClipRRect(
                borderRadius: AppRadius.pillAll,
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 6,
                  color: fg,
                  backgroundColor: fg.withOpacity(0.25),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
