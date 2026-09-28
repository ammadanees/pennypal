import 'package:flutter/material.dart';

import '../../core/theme/app_accents.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_radius.dart';

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
            Color.lerp(accent.color, Colors.black, 0.15) ?? accent.color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.color.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: AppRadius.mdAll,
      ),
      child: Center(
        child: Icon(icon, size: size * 0.52, color: accent.onColor),
      ),
    );
  }
}
