import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/brand_mark.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return AppScaffold(
      title: AppStrings.aboutTitle,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          const Align(alignment: Alignment.centerLeft, child: BrandMark()),
          AppSpacing.vSm,
          Text(AppStrings.tagline,
              style: t.bodyMedium?.copyWith(color: c.textSecondary)),
          AppSpacing.vLg,
          Text(AppStrings.aboutPurpose, style: t.bodyLarge),
          AppSpacing.vLg,
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: AppDimensions.iconMd, color: c.info),
                AppSpacing.hMd,
                Expanded(child: Text(AppStrings.notABank, style: t.bodyMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
