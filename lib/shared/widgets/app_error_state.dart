import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

/// Friendly error view. Deliberately takes no exception: raw errors are
/// never shown to students.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = AppStrings.errorGenericTitle,
    this.message = AppStrings.errorGenericMessage,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: AppDimensions.iconLg, color: c.textMuted),
            AppSpacing.vMd,
            Text(title,
                textAlign: TextAlign.center, style: context.text.titleLarge),
            AppSpacing.vSm,
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: c.textSecondary),
            ),
            if (onRetry != null) ...[
              AppSpacing.vLg,
              AppButton(
                label: AppStrings.tryAgain,
                icon: Icons.refresh,
                variant: AppButtonVariant.tonal,
                expand: false,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
