import 'package:flutter/material.dart';

/// One restrained elevation. Dark mode relies on borders instead of shadows.
abstract final class AppShadows {
  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return const [
      BoxShadow(
        color: Color(0x0F0F1B16),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ];
  }
}
