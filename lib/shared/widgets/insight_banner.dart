import 'package:flutter/material.dart';

import '../../core/theme/app_accents.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Pastel callout with a coloured icon, for friendly one-line insights.
class InsightBanner extends StatelessWidget {
  const InsightBanner({
    super.key,
    required this.message,
    this.accent = AppAccents.coral,
    this.icon = Icons.auto_awesome,
    this.onTap,
  });

  final String message;
  final AppAccent accent;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: message,
      button: onTap != null,
      excludeSemantics: true,
      child: Material(
        color: accent.color.withOpacity(0.13),
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(color: accent.color, shape: BoxShape.circle),
                  child: Icon(icon, size: 20, color: accent.onColor),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Text(
                    message,
                    style: context.text.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                  ),
                ),
                if (onTap != null) Icon(Icons.chevron_right, color: c.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
