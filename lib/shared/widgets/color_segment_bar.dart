import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';

class ColorSegment {
  const ColorSegment(this.value, this.color);

  final double value;
  final Color color;
}

/// A single bar split into coloured segments, like a spending "ribbon".
/// Always show names and amounts next to it.
class ColorSegmentBar extends StatelessWidget {
  const ColorSegmentBar({
    super.key,
    required this.segments,
    required this.trackColor,
    this.height = 12,
    this.gap = 3,
  });

  final List<ColorSegment> segments;
  final Color trackColor;
  final double height;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final visible = segments.where((s) => s.value > 0).toList();
    final total = visible.fold<double>(0, (sum, s) => sum + s.value);

    if (total <= 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(color: trackColor, borderRadius: AppRadius.pillAll),
      );
    }
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < visible.length; i++)
            Expanded(
              flex: math.max(1, (visible[i].value / total * 1000).round()),
              child: Container(
                height: height,
                margin: EdgeInsets.only(right: i == visible.length - 1 ? 0 : gap),
                decoration: BoxDecoration(
                  color: visible[i].color,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
