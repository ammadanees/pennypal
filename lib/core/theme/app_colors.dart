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
    primary: Color(0xFF00B074),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE6F8F0),
    secondary: Color(0xFFF59E0B),
    onSecondary: Color(0xFFFFFFFF),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    border: Color(0xFFE2E8F0),
    income: Color(0xFF10B981),
    expense: Color(0xFFF43F5E),
    savings: Color(0xFFF59E0B),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFF43F5E),
    info: Color(0xFF3B82F6),
    ink: Color(0xFF0F172A),
    onInk: Color(0xFFFFFFFF),
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF2EE6A6),
    onPrimary: Color(0xFF03241A),
    primarySoft: Color(0xFF0E2A20),
    secondary: Color(0xFFFBBF24),
    onSecondary: Color(0xFF1C1300),
    background: Color(0xFF090D14),
    surface: Color(0xFF121824),
    surfaceElevated: Color(0xFF1A2232),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    border: Color(0xFF1E293B),
    income: Color(0xFF34D399),
    expense: Color(0xFFFB7185),
    savings: Color(0xFFFBBF24),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFFB7185),
    info: Color(0xFF60A5FA),
    ink: Color(0xFF111827),
    onInk: Color(0xFFFFFFFF),
  );

  /// Vibrant gradients for fintech elements and cards
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00B074), Color(0xFF059669)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
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
