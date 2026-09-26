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
    required this.ink,
    required this.onInk,
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

  /// Dark hero surfaces (balance card, budget summary).
  final Color ink;
  final Color onInk;

  static const AppColors light = AppColors(
    primary: Color(0xFF00A86B),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE6F9F0),
    secondary: Color(0xFFFFB020),
    onSecondary: Color(0xFF2B1D00),
    background: Color(0xFFF6FAF8),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEDF6F2),
    textPrimary: Color(0xFF091F18),
    textSecondary: Color(0xFF42574F),
    textMuted: Color(0xFF677E75),
    border: Color(0xFFE2ECE7),
    income: Color(0xFF00B074),
    expense: Color(0xFFF04438),
    savings: Color(0xFFF79009),
    success: Color(0xFF00B074),
    warning: Color(0xFFF79009),
    error: Color(0xFFF04438),
    info: Color(0xFF2563EB),
    ink: Color(0xFF08221A),
    onInk: Color(0xFFFFFFFF),
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF2EE6A6),
    onPrimary: Color(0xFF03241A),
    primarySoft: Color(0xFF0E382B),
    secondary: Color(0xFFFFC043),
    onSecondary: Color(0xFF2B1D00),
    background: Color(0xFF061410),
    surface: Color(0xFF0C201A),
    surfaceElevated: Color(0xFF142D25),
    textPrimary: Color(0xFFEAF8F2),
    textSecondary: Color(0xFFB4C8BE),
    textMuted: Color(0xFF819A90),
    border: Color(0xFF1A3D32),
    income: Color(0xFF34D399),
    expense: Color(0xFFF87171),
    savings: Color(0xFFFBBF24),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    info: Color(0xFF60A5FA),
    ink: Color(0xFF0A261F),
    onInk: Color(0xFFFFFFFF),
  );

  /// Vibrant gradients for fintech elements and cards
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D3327), Color(0xFF041913)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00B574), Color(0xFF008C59)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC533), Color(0xFFFF9E00)],
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
    Color? ink,
    Color? onInk,
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
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
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
      ink: _mix(ink, other.ink, t),
      onInk: _mix(onInk, other.onInk, t),
    );
  }
}

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
