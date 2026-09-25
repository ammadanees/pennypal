import 'package:flutter/material.dart';

import '../constants/app_categories.dart';
import 'app_accents.dart';

/// Chart colours are the category accents, so a category looks the same in
/// every card, list and chart. Charts also show labels and percentages.
abstract final class AppChartColors {
  static Color forCategory(BuildContext context, ExpenseCategory category) =>
      AppAccents.forCategory(category).color;
}
