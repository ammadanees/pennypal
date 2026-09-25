import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Type scale: display 32 / headline 24 / title 18 / body 15 / label 13 / caption 12.
/// Headings use Plus Jakarta Sans, body text uses Inter.
abstract final class AppTextStyles {
  static TextStyle _heading(
    double size,
    FontWeight weight, {
    double height = 1.25,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle _body(double size, FontWeight weight, {double height = 1.5}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, height: height);

  static TextTheme textTheme(AppColors c) {
    return TextTheme(
      displayLarge: _heading(34, FontWeight.w800, letterSpacing: -0.6)
          .copyWith(color: c.textPrimary),
      headlineMedium: _heading(26, FontWeight.w800, letterSpacing: -0.4)
          .copyWith(color: c.textPrimary),
      titleLarge: _heading(19, FontWeight.w800).copyWith(color: c.textPrimary),
      titleMedium:
          _heading(16, FontWeight.w700).copyWith(color: c.textPrimary),
      bodyLarge: _body(15, FontWeight.w400).copyWith(color: c.textPrimary),
      bodyMedium: _body(15, FontWeight.w400).copyWith(color: c.textPrimary),
      bodySmall: _body(12, FontWeight.w400).copyWith(color: c.textSecondary),
      labelLarge: _body(13, FontWeight.w700).copyWith(color: c.textPrimary),
      labelMedium: _body(13, FontWeight.w500).copyWith(color: c.textSecondary),
      labelSmall: _body(12, FontWeight.w500).copyWith(color: c.textSecondary),
    );
  }

  /// Brand lockups (logo, splash). Sizes are chosen by the caller on purpose.
  static TextStyle brand(double size, Color color) =>
      _heading(size, FontWeight.w800, height: 1, letterSpacing: -0.5)
          .copyWith(color: color);

  // Money gets its own treatment: heavier weight and tabular figures so
  // digits line up when scanning a list.
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static TextStyle moneyHero(Color color) => _heading(44, FontWeight.w800,
          height: 1.1, letterSpacing: -0.5)
      .copyWith(color: color, fontFeatures: _tabular);

  static TextStyle moneyTitle(Color color) => _heading(19, FontWeight.w800)
      .copyWith(color: color, fontFeatures: _tabular);

  static TextStyle moneyBody(Color color) => _body(15, FontWeight.w700)
      .copyWith(color: color, fontFeatures: _tabular);
}

extension AppTextContext on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;
}
