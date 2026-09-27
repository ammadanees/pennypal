import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Sleek, high-performance obsidian card inspired by Apple Wallet & modern fintech.
/// Eliminates heavy radial shader passes for fluid 60-120fps scrolling.
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E4D38),
            Color(0xFF072B1F),
            Color(0xFF021610),
          ],
        ),
        borderRadius: AppRadius.xlAll,
        border: Border.all(
          color: const Color(0xFF2EE6A6).withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B074).withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
