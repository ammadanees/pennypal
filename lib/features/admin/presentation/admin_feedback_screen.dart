import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/admin_strings.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../data/admin_repository.dart';
import '../domain/admin_feedback_entry.dart';

class AdminFeedbackScreen extends ConsumerWidget {
  const AdminFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: AdminStrings.tabFeedback,
      body: AsyncValueView<List<AdminFeedbackEntry>>(
        value: ref.watch(adminFeedbackProvider),
        onRetry: () => ref.invalidate(adminFeedbackProvider),
        isEmpty: (list) => list.isEmpty,
        empty: const AppEmptyState(
          icon: Icons.favorite_outline,
          title: AdminStrings.noFeedbackTitle,
          message: AdminStrings.noFeedbackMessage,
        ),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppDimensions.bottomNavClearance,
          ),
          itemCount: list.length,
          separatorBuilder: (_, __) => AppSpacing.vSm,
          itemBuilder: (context, i) => _FeedbackCard(entry: list[i]),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.entry});

  final AdminFeedbackEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name.isEmpty ? 'Anonymous' : entry.name, style: t.titleMedium),
                    Text(entry.email, style: t.bodySmall),
                  ],
                ),
              ),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= entry.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 18,
                      color: AppAccents.amber.color,
                    ),
                ],
              ),
            ],
          ),
          Text(Formatters.relativeTime(entry.createdAt), style: t.bodySmall),
          if (entry.comments.isNotEmpty) ...[
            AppSpacing.vSm,
            Text(entry.comments, style: t.bodyMedium),
          ],
        ],
      ),
    );
  }
}
