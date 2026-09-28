import 'package:flutter/material.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/budget_progress.dart';
import '../../../shared/widgets/money_display.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/transaction_tile.dart';

class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({super.key, required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final content = switch (page) {
      0 => const _TrackIllustration(),
      1 => const _BudgetIllustration(),
      2 => const _SavingsIllustration(),
      _ => const _LearnIllustration(),
    };
    final accent =
        AppAccents.welcomePalette[page % AppAccents.welcomePalette.length];
    return Container(
      height: AppDimensions.illustrationHeight,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: accent.color.withOpacity(0.14),
        borderRadius: AppRadius.xlAll,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(child: content),
    );
  }
}

class _TrackIllustration extends StatelessWidget {
  const _TrackIllustration();

  @override
  Widget build(BuildContext context) {
    Widget row(double shift, Widget tile) => Transform.translate(
          offset: Offset(shift, 0),
          child: AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: tile,
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row(
          -AppSpacing.md,
          TransactionTile(
            title: 'Lunch',
            subtitle: 'Food, today 1:20 PM',
            amount: 450,
            kind: MoneyKind.expense,
            icon: ExpenseCategory.food.icon,
          ),
        ),
        AppSpacing.vSm,
        row(
          AppSpacing.md,
          const TransactionTile(
            title: 'Freelance project',
            subtitle: 'Income, yesterday',
            amount: 15000,
            kind: MoneyKind.income,
            icon: Icons.work_outline,
          ),
        ),
        AppSpacing.vSm,
        row(
          -AppSpacing.sm,
          TransactionTile(
            title: 'Bus pass',
            subtitle: 'Transport, 22 Sep',
            amount: 1200,
            kind: MoneyKind.expense,
            icon: ExpenseCategory.transport.icon,
          ),
        ),
      ],
    );
  }
}

class _BudgetIllustration extends StatelessWidget {
  const _BudgetIllustration();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProgressRing(
            value: 0.78,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('78%', style: context.text.titleLarge),
                Text('used', style: context.text.bodySmall),
              ],
            ),
          ),
          AppSpacing.vMd,
          const BudgetProgress(label: 'Food', spent: 12600, limit: 15000),
        ],
      ),
    );
  }
}

class _SavingsIllustration extends StatelessWidget {
  const _SavingsIllustration();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppDimensions.leadingIcon,
                height: AppDimensions.leadingIcon,
                decoration: BoxDecoration(
                  color: c.savings.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.laptop_mac_outlined,
                  size: AppDimensions.iconMd,
                  color: c.savings,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New laptop', style: t.titleMedium),
                    Text('Rs. 60,000 of Rs. 100,000', style: t.bodySmall),
                  ],
                ),
              ),
              Text('60%', style: t.labelLarge),
            ],
          ),
          AppSpacing.vMd,
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: AppDimensions.progressHeight,
              color: c.savings,
              backgroundColor: c.border,
            ),
          ),
          AppSpacing.vMd,
          Row(
            children: [
              Icon(Icons.event_outlined,
                  size: AppDimensions.iconSm, color: c.textSecondary),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'Rs. 5,000 a month, about 8 months to go',
                  style: t.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LearnIllustration extends StatelessWidget {
  const _LearnIllustration();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    Widget bubble({
      required String text,
      required bool fromUser,
    }) {
      return Align(
        alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: fromUser ? c.primary : c.surface,
              borderRadius: AppRadius.lgAll,
              border: fromUser ? null : Border.all(color: c.border),
            ),
            child: Text(
              text,
              style: t.bodyMedium?.copyWith(
                color: fromUser ? c.onPrimary : c.textPrimary,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.menu_book_outlined, color: c.primary),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Needs vs wants', style: t.titleMedium),
                    Text('3 min read', style: t.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vMd,
        bubble(text: 'How much should I save?', fromUser: true),
        AppSpacing.vSm,
        bubble(
          text: 'A fifth of what you earn is a common starting point.',
          fromUser: false,
        ),
      ],
    );
  }
}
