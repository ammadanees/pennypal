import 'package:flutter/material.dart';

import '../../core/theme/app_accents.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_radius.dart';

/// Rounded square with a vivid fill and a white (or dark) icon.
class AccentIconBox extends StatelessWidget {
  const AccentIconBox({
    super.key,
    required this.icon,
    required this.accent,
    this.size = AppDimensions.leadingIcon,
  });

  final IconData icon;
  final AppAccent accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.color,
            Color.lerp(accent.color, Colors.black, 0.10) ?? accent.color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.color.withOpacity(0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(icon, size: size * 0.5, color: accent.onColor),
    );
  }
}
