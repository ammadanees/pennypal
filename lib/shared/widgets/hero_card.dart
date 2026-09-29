import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'hex_pattern.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3730A3),
            Color(0xFF241C5A),
            Color(0xFF130E30),
          ],
          stops: [0.0, 0.58, 1.0],
        ),
        borderRadius: AppRadius.xlAll,
        border: Border.all(
          color: const Color(0xFF818CF8).withOpacity(0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (glow ?? const Color(0xFF4F46E5)).withOpacity(0.32),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.18),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: HexPatternPainter(
                color: Colors.white,
                opacity: 0.07,
                cell: 22,
              ),
            ),
          ),
          Positioned(
            top: -30,
            right: -25,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF818CF8).withOpacity(0.28),
                    const Color(0xFF818CF8).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC084FC).withOpacity(0.16),
                    const Color(0xFFC084FC).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
