import 'package:flutter/material.dart';

/// Single source of truth for every colour in PennyPal.
/// Screens read colours via `context.colors`; never use raw Color values.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.income,
    required this.expense,
    required this.savings,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  final Color primary;
  final Color onPrimary;
  final Color primarySoft;
  final Color secondary;
  final Color onSecondary;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color income;
  final Color expense;
  final Color savings;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  static const AppColors light = AppColors(
    primary: Color(0xFF0F7B5F),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE3F2EC),
    secondary: Color(0xFFF2B134),
    onSecondary: Color(0xFF3A2A00),
    background: Color(0xFFF6F8F7),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0F4F2),
    textPrimary: Color(0xFF0F1B16),
    textSecondary: Color(0xFF4A5A53),
    textMuted: Color(0xFF66766F),
    border: Color(0xFFDFE7E3),
    income: Color(0xFF17824B),
    expense: Color(0xFFC6423E),
    savings: Color(0xFFC48A0F),
    success: Color(0xFF17824B),
    warning: Color(0xFFB87500),
    error: Color(0xFFB83232),
    info: Color(0xFF2A6FB5),
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF3FC79F),
    onPrimary: Color(0xFF06251C),
    primarySoft: Color(0xFF173229),
    secondary: Color(0xFFF5C25E),
    onSecondary: Color(0xFF2B1F00),
    background: Color(0xFF0E1512),
    surface: Color(0xFF16201C),
    surfaceElevated: Color(0xFF1E2B26),
    textPrimary: Color(0xFFEAF2EE),
    textSecondary: Color(0xFFB4C4BC),
    textMuted: Color(0xFF8A9B93),
    border: Color(0xFF2A3832),
    income: Color(0xFF4AD08A),
    expense: Color(0xFFF07A76),
    savings: Color(0xFFF5C25E),
    success: Color(0xFF4AD08A),
    warning: Color(0xFFF2B84B),
    error: Color(0xFFF28B82),
    info: Color(0xFF6BB0EE),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primarySoft,
    Color? secondary,
    Color? onSecondary,
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? income,
    Color? expense,
    Color? savings,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primarySoft: primarySoft ?? this.primarySoft,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      savings: savings ?? this.savings,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: _mix(primary, other.primary, t),
      onPrimary: _mix(onPrimary, other.onPrimary, t),
      primarySoft: _mix(primarySoft, other.primarySoft, t),
      secondary: _mix(secondary, other.secondary, t),
      onSecondary: _mix(onSecondary, other.onSecondary, t),
      background: _mix(background, other.background, t),
      surface: _mix(surface, other.surface, t),
      surfaceElevated: _mix(surfaceElevated, other.surfaceElevated, t),
      textPrimary: _mix(textPrimary, other.textPrimary, t),
      textSecondary: _mix(textSecondary, other.textSecondary, t),
      textMuted: _mix(textMuted, other.textMuted, t),
      border: _mix(border, other.border, t),
      income: _mix(income, other.income, t),
      expense: _mix(expense, other.expense, t),
      savings: _mix(savings, other.savings, t),
      success: _mix(success, other.success, t),
      warning: _mix(warning, other.warning, t),
      error: _mix(error, other.error, t),
      info: _mix(info, other.info, t),
    );
  }
}

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
