import 'package:flutter/material.dart';

import '../constants/app_categories.dart';
import 'app_accents.dart';

abstract final class AppChartColors {
  static Color forCategory(BuildContext context, ExpenseCategory category) =>
      AppAccents.forCategory(category).color;
}
