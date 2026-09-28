import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.showName = true, this.onPrimary = false});

  final bool showName;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tile = onPrimary ? c.secondary : c.primary;
    final glyph = onPrimary ? c.onSecondary : c.onPrimary;
    final name = onPrimary ? c.onPrimary : c.textPrimary;

    return Semantics(
      label: AppStrings.appName,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppDimensions.brandTile,
            height: AppDimensions.brandTile,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: tile, borderRadius: AppRadius.smAll),
            child: Text(
              AppStrings.appName.substring(0, 1),
              style: context.text.titleLarge?.copyWith(color: glyph),
            ),
          ),
          if (showName) ...[
            AppSpacing.hSm,
            Text(
              AppStrings.appName,
              style: context.text.titleLarge?.copyWith(color: name),
            ),
          ],
        ],
      ),
    );
  }
}
