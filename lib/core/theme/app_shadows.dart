import 'package:flutter/material.dart';

abstract final class AppShadows {
  /// Soft, wide shadow in light mode. Dark mode relies on colour contrast.
  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return const [
      BoxShadow(
        color: Color(0x14102A22),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ];
  }

  /// Coloured glow under vivid cards.
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.28),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];
}
