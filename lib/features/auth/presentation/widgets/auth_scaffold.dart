import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/brand_mark.dart';
import '../../../../shared/widgets/hex_pattern.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final wide = context.screenSize == ScreenSize.expanded;

    final form = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppDimensions.authFormWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!wide) ...[
            const Align(alignment: Alignment.centerLeft, child: BrandMark()),
            AppSpacing.vLg,
          ],
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: AppStrings.back,
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          Semantics(
            header: true,
            child: Text(title, style: context.text.headlineMedium),
          ),
          AppSpacing.vSm,
          Text(
            subtitle,
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.textSecondary),
          ),
          AppSpacing.vLg,
          child,
          if (footer != null) ...[AppSpacing.vLg, footer!],
        ],
      ),
    );

    final scrollable = SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(wide ? AppSpacing.xl : AppSpacing.lg),
          child: form,
        ),
      ),
    );

    return Scaffold(
      body: wide
          ? Row(
              children: [
                const Expanded(flex: 5, child: _BrandPanel()),
                Expanded(flex: 6, child: scrollable),
              ],
            )
          : scrollable,
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Container(
      color: c.primary,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: HexPatternPainter(color: c.onPrimary, opacity: 0.09),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(onPrimary: true),
                AppSpacing.vXl,
                Text(
                  AppStrings.tagline,
                  style: t.displayLarge?.copyWith(color: c.onPrimary),
                ),
                AppSpacing.vMd,
                Text(
                  AppStrings.authPanelBody,
                  style: t.bodyLarge
                      ?.copyWith(color: c.onPrimary.withOpacity(0.85)),
                ),
                AppSpacing.vXl,
                for (final point in AppStrings.authPanelPoints)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: AppDimensions.iconMd,
                          color: c.secondary,
                        ),
                        AppSpacing.hSm,
                        Expanded(
                          child: Text(
                            point,
                            style: t.bodyLarge?.copyWith(color: c.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
