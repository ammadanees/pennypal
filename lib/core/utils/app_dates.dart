import 'dart:math' as math;

import 'package:intl/intl.dart';

abstract final class AppDates {
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month);

  static bool sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  /// "2026-09": used as the id of a month's budget.
  static String monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static String monthLabel(DateTime d) => DateFormat('MMMM y').format(d);

  static String shortDate(DateTime d) => DateFormat('d MMM y').format(d);

  /// Adds calendar months, clamping the day (31 Jan + 1 month = 28/29 Feb).
  static DateTime addMonths(DateTime d, int months) {
    final first = DateTime(d.year, d.month + months);
    final lastDay = DateTime(first.year, first.month + 1, 0).day;
    return DateTime(first.year, first.month, math.min(d.day, lastDay));
  }

  static int monthsBetween(DateTime from, DateTime to) =>
      (to.year - from.year) * 12 + (to.month - from.month);
}
