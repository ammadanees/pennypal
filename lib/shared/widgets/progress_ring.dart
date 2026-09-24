import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_durations.dart';

/// Donut progress indicator with an optional centre widget.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = AppDimensions.ringSize,
    this.strokeWidth = AppDimensions.ringStroke,
    this.color,
    this.child,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: AppDurations.slow,
        curve: Curves.easeOutCubic,
        builder: (_, progress, __) => CustomPaint(
          painter: _RingPainter(
            progress: progress,
            color: color ?? c.primary,
            track: c.border,
            strokeWidth: strokeWidth,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base..color = track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
