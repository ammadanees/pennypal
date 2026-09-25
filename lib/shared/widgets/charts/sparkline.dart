import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_durations.dart';

/// Smooth line with a soft fill, for trends on dark hero cards.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.height = 72,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppDurations.slow,
          curve: Curves.easeOutCubic,
          builder: (_, t, __) => CustomPaint(
            painter: _SparklinePainter(values: values, color: color, progress: t),
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.values,
    required this.color,
    required this.progress,
  });

  final List<double> values;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV) == 0 ? 1.0 : maxV - minV;
    const pad = 6.0;
    final usable = size.height - pad * 2;

    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(
          i / (values.length - 1) * size.width,
          size.height - pad - (values[i] - minV) / span * usable * progress,
        ),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final mid = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        (points[i - 1].dy + points[i].dy) / 2,
      );
      line.quadraticBezierTo(points[i - 1].dx, points[i - 1].dy, mid.dx, mid.dy);
    }
    line.lineTo(points.last.dx, points.last.dy);

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withOpacity(0.16));
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(points.last, 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.progress != progress || old.values != values || old.color != color;
}
