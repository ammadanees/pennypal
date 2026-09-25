import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// Rounded card with a soft shadow in light mode and a hairline border in
/// dark mode.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final brightness = Theme.of(context).brightness;
    final content = Padding(padding: padding, child: child);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        boxShadow: color == null ? AppShadows.card(brightness) : const [],
      ),
      child: Material(
        color: color ?? c.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(
            color: (color == null && brightness == Brightness.dark)
                ? c.border
                : Colors.transparent,
          ),
        ),
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
