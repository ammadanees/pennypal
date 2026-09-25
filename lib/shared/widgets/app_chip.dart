import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// Selectable pill for filters and option pickers. Selected is solid brand
/// colour so the active choice is obvious at a glance.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.onPrimary : c.textPrimary;
    return ChoiceChip(
      label: Text(label),
      avatar: icon == null
          ? null
          : Icon(icon, size: AppDimensions.iconSm, color: fg),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: c.primary,
      backgroundColor: c.surface,
      side: BorderSide(color: selected ? c.primary : c.border),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
      labelStyle: context.text.labelLarge?.copyWith(color: fg),
    );
  }
}
