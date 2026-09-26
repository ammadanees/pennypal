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
    final accentGlow = c.secondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.glow(glowColor),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0E382B),
                Color(0xFF08221A),
                Color(0xFF03140F),
              ],
            ),
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: Colors.white.withOpacity(0.14),
              width: 1.2,
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(
                  painter: HexPatternPainter(
                    color: Colors.white,
                    opacity: 0.05,
                    cell: 28,
                  ),
                ),
              ),
              // Top-Right Primary Emerald Glow
              Positioned(
                top: -_glowSize / 2.2,
                right: -_glowSize / 3,
                child: Container(
                  width: _glowSize,
                  height: _glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        glowColor.withOpacity(0.55),
                        glowColor.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom-Left Warm Gold Glow
              Positioned(
                bottom: -_glowSize / 2.5,
                left: -_glowSize / 3,
                child: Container(
                  width: _glowSize * 0.9,
                  height: _glowSize * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentGlow.withOpacity(0.18),
                        accentGlow.withOpacity(0),
                      ],
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
