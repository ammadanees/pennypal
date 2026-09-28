import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_durations.dart';

class DonutSegment {
  const DonutSegment(this.value, this.color);

  final double value;
  final Color color;
}

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    required this.semanticLabel,
    this.size = 168,
    this.strokeWidth = 24,
    this.center,
  });

  final List<DonutSegment> segments;
  final String semanticLabel;
  final double size;
  final double strokeWidth;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final track = context.colors.border;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppDurations.slow,
          curve: Curves.easeOutCubic,
          builder: (_, progress, __) => CustomPaint(
            painter: _DonutPainter(
              segments: segments,
              progress: progress,
              track: track,
              strokeWidth: strokeWidth,
            ),
            child: Center(child: center),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.segments,
    required this.progress,
    required this.track,
    required this.strokeWidth,
  });

  final List<DonutSegment> segments;
  final double progress;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) {
      canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
      return;
    }

    final gap = segments.length > 1 ? 0.04 : 0.0;
    var start = -math.pi / 2;
    for (final segment in segments) {
      final sweep = segment.value / total * math.pi * 2 * progress;
      final drawn = math.max(0.0, sweep - gap);
      if (drawn > 0) {
        canvas.drawArc(
            rect, start + gap / 2, drawn, false, paint..color = segment.color);
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress ||
      old.segments != segments ||
      old.track != track;
}
