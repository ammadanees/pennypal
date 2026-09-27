import 'package:flutter/material.dart';

abstract final class AppShadows {
  /// Subtle, crisp modern ambient shadow for cards.
  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        BoxShadow(
          color: Color(0x2E000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x0A0F172A),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ];
  }

  /// Ambient floating shadow for modern floating navigation bar
  static List<BoxShadow> floatingNav(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x120F172A),
        blurRadius: 14,
        offset: Offset(0, 4),
      ),
    ];
  }

  /// Subtle tint glow under vivid cards.
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.18),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
