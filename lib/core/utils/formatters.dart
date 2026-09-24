import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_strings.dart';

abstract final class Formatters {
  static final NumberFormat _whole = NumberFormat('#,##0');
  static final NumberFormat _decimal = NumberFormat('#,##0.00');

  /// 52450 -> "52,450", 450.5 -> "450.50"
  static String number(double value) =>
      (value.abs() % 1 == 0 ? _whole : _decimal).format(value);

  static String money(double value,
          {String currency = AppStrings.defaultCurrency}) =>
      '$currency ${number(value)}';

  static String percent(double ratio) => '${(ratio * 100).round()}%';

  static String dayLabel(DateTime date, {DateTime? now}) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final days = today.difference(DateUtils.dateOnly(date)).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return DateFormat('d MMM').format(date);
  }

  /// 450 -> "450", 31200 -> "31.2k", 1200000 -> "1.2M". For chart labels.
  static String compact(double value) {
    final a = value.abs();
    final String text;
    if (a >= 1000000) {
      text = '${_trim(a / 1000000)}M';
    } else if (a >= 1000) {
      text = '${_trim(a / 1000)}k';
    } else {
      text = a.round().toString();
    }
    return value < 0 ? '-$text' : text;
  }

  static String _trim(double v) {
    final t = v.toStringAsFixed(1);
    return t.endsWith('.0') ? t.substring(0, t.length - 2) : t;
  }

  static String time(DateTime date) => DateFormat('h:mm a').format(date);
}
