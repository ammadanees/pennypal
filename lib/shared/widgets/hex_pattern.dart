import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Honeycomb outline pattern (the "bee" in NextGen BudgetBee).
/// [reveal] grows the pattern outward from the centre (0 to 1).
class HexPatternPainter extends CustomPainter {
  const HexPatternPainter({
    required this.color,
    this.opacity = 0.08,
    this.reveal = 1,
    this.cell = 30,
  });

  final Color color;
  final double opacity;
  final double reveal;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    if (reveal <= 0) return;
    final center = size.center(Offset.zero);
    final maxDist = center.distance;
    final reach = reveal * maxDist * 1.15;
    final hexWidth = math.sqrt(3) * cell;
    final rowHeight = cell * 1.5;
    final rows = (size.height / rowHeight).ceil() + 2;
    final cols = (size.width / hexWidth).ceil() + 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var r = -1; r < rows; r++) {
      for (var c = -1; c < cols; c++) {
        final cx = c * hexWidth + (r.isOdd ? hexWidth / 2 : 0);
        final cy = r * rowHeight;
        final distance = (Offset(cx, cy) - center).distance;
        if (distance > reach) continue;
        final edge = ((reach - distance) / (maxDist * 0.35)).clamp(0.0, 1.0);
        final falloff = 1 - (distance / maxDist).clamp(0.0, 1.0) * 0.6;
        paint.color = color.withOpacity(opacity * edge * falloff);
        canvas.drawPath(_hexagon(cx, cy, cell), paint);
      }
    }
  }

  static Path _hexagon(double cx, double cy, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = math.pi / 3 * i - math.pi / 6;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(HexPatternPainter old) =>
      old.reveal != reveal || old.color != color || old.opacity != opacity;
}
