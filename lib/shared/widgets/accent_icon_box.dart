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
      decoration: BoxDecoration(color: accent.color, borderRadius: AppRadius.mdAll),
      child: Icon(icon, size: size * 0.5, color: accent.onColor),
    );
  }
}
