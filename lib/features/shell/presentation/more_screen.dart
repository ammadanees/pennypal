import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/learning_strings.dart';
import '../../../core/constants/report_strings.dart';
import '../../../core/constants/step5_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'More',
      body: ListView(
        padding: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppDimensions.bottomNavClearance,
        ),
        children: [
          _MoreTile(
            icon: Icons.handshake_outlined,
            label: 'Borrow & Lend Tracker',
            onTap: () => context.push(AppRoutes.debts),
          ),
          AppSpacing.vSm,
          _MoreTile(
            icon: Icons.repeat_rounded,
            label: 'Subscriptions & Bills',
            onTap: () => context.push(AppRoutes.subscriptions),
          ),
          AppSpacing.vSm,
          _MoreTile(
            icon: Icons.credit_card_rounded,
            label: 'Payment Cards & Wallets',
            onTap: () => context.push(AppRoutes.cards),
          ),
          AppSpacing.vSm,
          _MoreTile(
            icon: Icons.insights_outlined,
            label: ReportStrings.title,
            onTap: () => context.push(AppRoutes.reports),
          ),
          AppSpacing.vSm,
          _MoreTile(
            icon: Icons.menu_book_outlined,
            label: LearningStrings.title,
            onTap: () => context.push(AppRoutes.learning),
          ),
          AppSpacing.vSm,
          _MoreTile(
            icon: Icons.auto_awesome,
            label: Step5Strings.assistantTitle,
            onTap: () => context.push(AppRoutes.assistant),
          ),
          AppSpacing.vSm,
          _MoreTile(
            icon: Icons.favorite_outline,
            label: Step5Strings.feedbackTitle,
            onTap: () => context.push(AppRoutes.feedback),
          ),
          AppSpacing.vSm,
          _MoreTile(
            icon: Icons.support_agent_outlined,
            label: Step5Strings.supportTitle,
            onTap: () => context.push(AppRoutes.support),
          ),
          AppSpacing.vSm,
          _MoreTile(
            icon: Icons.person_outline,
            label: 'Profile and settings',
            onTap: () => context.push(AppRoutes.profile),
          ),
          AppSpacing.vSm,
          _MoreTile(
            icon: Icons.info_outline,
            label: AppStrings.aboutTitle,
            onTap: () => context.push(AppRoutes.about),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconMd, color: c.primary),
          AppSpacing.hMd,
          Expanded(child: Text(label, style: context.text.titleMedium)),
          Icon(Icons.chevron_right, color: c.textMuted),
        ],
      ),
    );
  }
}
