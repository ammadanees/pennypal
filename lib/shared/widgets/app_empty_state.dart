import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppDimensions.emptyIllustration,
              height: AppDimensions.emptyIllustration,
              decoration:
                  BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
              child: Icon(icon, size: AppDimensions.iconLg, color: c.primary),
            ),
            AppSpacing.vLg,
            Text(title,
                textAlign: TextAlign.center, style: context.text.titleLarge),
            AppSpacing.vSm,
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: c.textSecondary),
            ),
            if (actionLabel != null) ...[
              AppSpacing.vLg,
              AppButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}
