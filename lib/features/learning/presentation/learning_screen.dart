import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/learning_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_durations.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/adaptive_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../data/learning_progress_repository.dart';
import '../data/lessons.dart';
import '../domain/lesson.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  LearningTopic? _topic;

  @override
  Widget build(BuildContext context) {
    final read = ref.watch(readLessonsProvider).valueOrNull ?? const <String>{};
    final visible = [
      for (final l in bundledLessons)
        if (_topic == null || l.topic == _topic) l,
    ];
    final firstUnread = bundledLessons.where((l) => !read.contains(l.id)).firstOrNull;

    return AppScaffold(
      title: LearningStrings.title,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 800 ? 2 : 1;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              _ProgressCard(
                readCount: bundledLessons.where((l) => read.contains(l.id)).length,
                total: bundledLessons.length,
                onStart: firstUnread == null
                    ? null
                    : () => context.push('${AppRoutes.lessonBase}/${firstUnread.id}'),
              ),
              AppSpacing.vMd,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    AppChip(
                      label: LearningStrings.allTopics,
                      selected: _topic == null,
                      onSelected: () => setState(() => _topic = null),
                    ),
                    for (final topic in LearningTopic.values) ...[
                      AppSpacing.hSm,
                      AppChip(
                        label: topic.label,
                        icon: topic.icon,
                        selected: _topic == topic,
                        onSelected: () => setState(
                          () => _topic = _topic == topic ? null : topic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.vMd,
              if (visible.isEmpty)
                const AppEmptyState(
                  icon: Icons.menu_book_outlined,
                  title: LearningStrings.noLessonsTitle,
                  message: LearningStrings.noLessonsMessage,
                )
              else
                AdaptiveGrid(
                  columns: columns,
                  children: [
                    for (final lesson in visible)
                      _LessonCard(lesson: lesson, isRead: read.contains(lesson.id)),
                  ],
                ),
              Text(LearningStrings.disclaimer, style: context.text.bodySmall),
              AppSpacing.vLg,
            ],
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.readCount,
    required this.total,
    required this.onStart,
  });

  final int readCount;
  final int total;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final ratio = total == 0 ? 0.0 : readCount / total;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LearningStrings.progressTitle, style: t.titleMedium),
          AppSpacing.vXs,
          Text(
            readCount == 0
                ? LearningStrings.startNudge
                : LearningStrings.readCount(readCount, total),
            style: t.bodyMedium?.copyWith(color: c.textSecondary),
          ),
          AppSpacing.vMd,
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: AppDurations.normal,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: AppDimensions.progressHeight,
                color: c.primary,
                backgroundColor: c.border,
              ),
            ),
          ),
          if (onStart != null) ...[
            AppSpacing.vMd,
            AppButton(
              label: readCount == 0
                  ? LearningStrings.startHere
                  : LearningStrings.nextLesson,
              icon: Icons.play_arrow_rounded,
              variant: AppButtonVariant.tonal,
              expand: false,
              onPressed: onStart,
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, required this.isRead});

  final Lesson lesson;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Semantics(
      label: '${lesson.title}. ${lesson.topic.label}. '
          '${LearningStrings.minutes(lesson.readMinutes)}.${isRead ? ' Read.' : ''}',
      button: true,
      excludeSemantics: true,
      child: AppCard(
        onTap: () => context.push('${AppRoutes.lessonBase}/${lesson.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppDimensions.leadingIcon,
              height: AppDimensions.leadingIcon,
              decoration:
                  BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
              child: Icon(lesson.topic.icon,
                  size: AppDimensions.iconMd, color: c.primary),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: t.titleMedium),
                  AppSpacing.vXs,
                  Text(
                    lesson.summary,
                    style: t.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vSm,
                  Text(
                    '${lesson.topic.label}, ${lesson.level.label}, '
                    '${LearningStrings.minutes(lesson.readMinutes)}',
                    style: t.labelSmall,
                  ),
                ],
              ),
            ),
            if (isRead) ...[
              AppSpacing.hSm,
              Icon(Icons.check_circle,
                  size: AppDimensions.iconMd, color: c.success),
            ],
          ],
        ),
      ),
    );
  }
}
