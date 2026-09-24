import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_durations.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand_mark.dart';
import 'onboarding_controller.dart';
import 'welcome_illustrations.dart';

/// First-launch introduction. The router skips it once it has been seen.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  static const double _maxWidth = 520;
  final PageController _pages = PageController();
  int _page = 0;

  int get _count => AppStrings.welcomeTitles.length;
  bool get _isLast => _page == _count - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish(String route) async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
    if (mounted) context.go(route);
  }

  void _next() => _pages.nextPage(
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
      );

  @override
  Widget build(BuildContext context) {
    final gutter = context.isCompact ? AppSpacing.md : AppSpacing.lg;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: BrandMark(),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: _count,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (_, i) => _WelcomePage(index: i),
                    ),
                  ),
                  _Dots(count: _count, index: _page),
                  AppSpacing.vLg,
                  AppButton(
                    label: _isLast
                        ? AppStrings.welcomeCreateAccount
                        : AppStrings.next,
                    onPressed:
                        _isLast ? () => _finish(AppRoutes.register) : _next,
                  ),
                  AppSpacing.vSm,
                  AppButton(
                    label: _isLast
                        ? AppStrings.welcomeHaveAccount
                        : AppStrings.skip,
                    variant: AppButtonVariant.text,
                    onPressed: () => _finish(AppRoutes.login),
                  ),
                  AppSpacing.vSm,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final isLast = index == AppStrings.welcomeTitles.length - 1;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WelcomeIllustration(page: index),
              AppSpacing.vLg,
              Semantics(
                header: true,
                child: Text(
                  AppStrings.welcomeTitles[index],
                  style: context.text.headlineMedium,
                ),
              ),
              AppSpacing.vSm,
              Text(
                AppStrings.welcomeBodies[index],
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.textSecondary),
              ),
              if (isLast) ...[
                AppSpacing.vMd,
                Text(AppStrings.notABank, style: context.text.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  static const double _dot = 8;
  static const double _activeWidth = 24;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Page ${index + 1} of $count',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppDurations.normal,
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width: i == index ? _activeWidth : _dot,
              height: _dot,
              decoration: BoxDecoration(
                color: i == index ? c.primary : c.border,
                borderRadius: AppRadius.pillAll,
              ),
            ),
        ],
      ),
    );
  }
}
