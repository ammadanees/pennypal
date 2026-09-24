import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, tonal, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (variant) {
      AppButtonVariant.primary => (c.primary, c.onPrimary),
      AppButtonVariant.tonal => (c.primarySoft, c.primary),
      AppButtonVariant.outlined => (c.surface, c.textPrimary),
      AppButtonVariant.text => (Colors.transparent, c.primary),
    };

    final style = FilledButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: isLoading ? bg : c.border,
      disabledForegroundColor: isLoading ? fg : c.textMuted,
      minimumSize: Size(expand ? double.infinity : 0, AppDimensions.buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      elevation: 0,
      textStyle: context.text.labelLarge,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: variant == AppButtonVariant.outlined
            ? BorderSide(color: c.border)
            : BorderSide.none,
      ),
    );

    final child = isLoading
        ? Semantics(
            label: 'Loading',
            child: SizedBox(
              width: AppDimensions.iconSm,
              height: AppDimensions.iconSm,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppDimensions.iconSm),
                AppSpacing.hSm,
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );
  }
}
