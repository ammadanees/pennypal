import 'package:flutter/material.dart';

import '../constants/app_categories.dart';

/// A vivid fill with a text/icon colour that stays readable on it.
class AppAccent {
  const AppAccent(this.color, this.onColor);

  final Color color;
  final Color onColor;
}

/// The vibrant palette. Each expense category owns one colour, and it is
/// the same colour everywhere: cards, icons, donut and legend.
abstract final class AppAccents {
  static const Color _white = Color(0xFFFFFFFF);

  static const AppAccent coral = AppAccent(Color(0xFFE5533D), _white);
  static const AppAccent purple = AppAccent(Color(0xFF6D4AE8), _white);
  static const AppAccent blue = AppAccent(Color(0xFF2563EB), _white);
  static const AppAccent green = AppAccent(Color(0xFF0F9D75), _white);
  static const AppAccent amber = AppAccent(Color(0xFFD97706), _white);
  static const AppAccent pink = AppAccent(Color(0xFFD6337F), _white);
  static const AppAccent cyan = AppAccent(Color(0xFF0B7F92), _white);
  static const AppAccent slate = AppAccent(Color(0xFF5B6B85), _white);

  static const List<AppAccent> goalPalette = [amber, blue, coral, purple, green, pink];
  static const List<AppAccent> welcomePalette = [blue, coral, amber, purple];

  static AppAccent forIndex(int index) => goalPalette[index % goalPalette.length];

  static AppAccent forCategory(ExpenseCategory category) => switch (category) {
        ExpenseCategory.food => coral,
        ExpenseCategory.transport => purple,
        ExpenseCategory.education => blue,
        ExpenseCategory.shopping => amber,
        ExpenseCategory.entertainment => pink,
        ExpenseCategory.bills => cyan,
        ExpenseCategory.savings => green,
        ExpenseCategory.miscellaneous => slate,
      };
}
