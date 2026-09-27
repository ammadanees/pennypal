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
    this.gradient,
    this.borderRadius,
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final brightness = Theme.of(context).brightness;
    final r = borderRadius ?? AppRadius.lgAll;
    final content = Padding(padding: padding, child: child);

    final borderColor = color == null
        ? (brightness == Brightness.dark
            ? c.border
            : c.border.withOpacity(0.65))
        : Colors.transparent;

    final shouldClip = onTap != null || gradient != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? c.surface) : null,
        gradient: gradient,
        borderRadius: r,
        border: border ?? Border.all(color: borderColor, width: 1),
        boxShadow: color == null ? AppShadows.card(brightness) : const [],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: shouldClip ? Clip.antiAlias : Clip.none,
        borderRadius: r,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
