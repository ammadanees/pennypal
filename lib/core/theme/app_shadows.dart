import 'package:flutter/material.dart';

abstract final class AppShadows {
  /// Soft, multi-layered ambient shadow for cards.
  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x0A0B1B17),
        blurRadius: 20,
        offset: Offset(0, 6),
      ),
      BoxShadow(
        color: Color(0x06000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ];
  }

  /// Ambient floating shadow for modern floating navigation bar
  static List<BoxShadow> floatingNav(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.50),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: const Color(0xFF2EE6A6).withOpacity(0.08),
          blurRadius: 18,
          offset: const Offset(0, -1),
        ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(0xFF0C2B22).withOpacity(0.12),
        blurRadius: 30,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Coloured glow under vivid cards.
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.32),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ];
}
