import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Builds ThemeData from the tokens. Change a token, the whole app follows.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final textTheme = AppTextStyles.textTheme(c);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.secondary,
      onSecondary: c.onSecondary,
      error: c.error,
      onError: c.onPrimary,
      surface: c.surface,
      onSurface: c.textPrimary,
      outline: c.border,
      outlineVariant: c.border,
      primaryContainer: c.primarySoft,
      onPrimaryContainer: c.primary,
      secondaryContainer: c.primarySoft,
      onSecondaryContainer: c.primary,
      surfaceContainerLowest: c.surface,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surfaceElevated,
      surfaceContainerHigh: c.surfaceElevated,
      surfaceContainerHighest: c.surfaceElevated,
    );

    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[c],
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(color: c.primary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.textMuted),
        errorStyle: textTheme.bodySmall?.copyWith(color: c.error),
        border: border(c.border),
        enabledBorder: border(c.border),
        focusedBorder: border(c.primary, width: 2),
        errorBorder: border(c.error),
        focusedErrorBorder: border(c.error, width: 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: c.surface,
        elevation: 0,
        height: 72,
        indicatorColor: c.primary,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? c.primary
                : c.textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppDimensions.iconMd,
            color: states.contains(WidgetState.selected)
                ? c.onPrimary
                : c.textSecondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primary,
        selectedIconTheme: IconThemeData(color: c.onPrimary),
        unselectedIconTheme: IconThemeData(color: c.textSecondary),
        selectedLabelTextStyle:
            textTheme.labelLarge?.copyWith(color: c.primary),
        unselectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: c.textSecondary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.border,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: c.border)),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? c.primary
                : c.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? c.onPrimary
                : c.textSecondary,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 2,
        extendedTextStyle: textTheme.labelLarge?.copyWith(color: c.onPrimary),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.background),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
    );
  }
}
