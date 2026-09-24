import 'package:flutter/material.dart';

import '../constants/app_categories.dart';

/// Categorical palette for charts. Chosen to stay distinguishable for
/// common types of colour blindness; charts also always show labels and
/// percentages, so colour is never the only cue.
abstract final class AppChartColors {
  static const List<Color> _light = [
    Color(0xFF0F7B5F), // teal
    Color(0xFF2A6FB5), // blue
    Color(0xFFC48A0F), // amber
    Color(0xFF8E5EA2), // purple
    Color(0xFFC6423E), // red
    Color(0xFF5B6B75), // slate
    Color(0xFF0E9AA7), // cyan
    Color(0xFF9A6B4F), // brown
  ];

  static const List<Color> _dark = [
    Color(0xFF3FC79F),
    Color(0xFF6BB0EE),
    Color(0xFFF5C25E),
    Color(0xFFB48CCB),
    Color(0xFFF07A76),
    Color(0xFFB4C4BC),
    Color(0xFF4DD0DC),
    Color(0xFFD2A084),
  ];

  static Color forCategory(BuildContext context, ExpenseCategory category) {
    final palette = Theme.of(context).brightness == Brightness.dark ? _dark : _light;
    return palette[category.index % palette.length];
  }
}
