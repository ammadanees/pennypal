import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import 'hex_pattern.dart';

/// Dark, high-contrast card for the most important number on a screen.
/// A honeycomb texture and a coloured glow give it depth without images.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.child,
    this.glow,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final Color? glow;
  final EdgeInsets padding;

  static const double _glowSize = 240;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final glowColor = glow ?? c.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.glow(glowColor),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Container(
          color: c.ink,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: HexPatternPainter(color: c.onInk, opacity: 0.07, cell: 26),
                ),
              ),
              Positioned(
                top: -_glowSize / 2.4,
                right: -_glowSize / 3,
                child: Container(
                  width: _glowSize,
                  height: _glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [glowColor.withOpacity(0.6), glowColor.withOpacity(0)],
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
