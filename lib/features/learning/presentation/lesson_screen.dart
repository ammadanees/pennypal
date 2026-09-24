import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/learning_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/hex_pattern.dart';
import '../data/learning_progress_repository.dart';
import '../data/lessons.dart';
import '../domain/lesson.dart';

class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = bundledLessons.indexWhere((l) => l.id == lessonId);
    if (index < 0) {
      return AppScaffold(
        title: LearningStrings.title,
        body: AppEmptyState(
          icon: Icons.menu_book_outlined,
          title: LearningStrings.notFoundTitle,
          message: LearningStrings.notFoundMessage,
          actionLabel: LearningStrings.backToLessons,
          onAction: () => context.go(AppRoutes.learning),
        ),
      );
    }

    final lesson = bundledLessons[index];
    final next = index + 1 < bundledLessons.length ? bundledLessons[index + 1] : null;
    final isRead = ref.watch(readLessonsProvider).valueOrNull?.contains(lesson.id) ?? false;
    final t = context.text;
    final c = context.colors;

    return AppScaffold(
      title: lesson.topic.label,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _LessonHeader(lesson: lesson),
          AppSpacing.vMd,
          Semantics(header: true, child: Text(lesson.title, style: t.headlineMedium)),
          AppSpacing.vXs,
          Text(
            '${lesson.level.label}, ${LearningStrings.minutes(lesson.readMinutes)}',
            style: t.labelMedium,
          ),
          AppSpacing.vMd,
          Text(lesson.summary,
              style: t.bodyLarge?.copyWith(color: c.textSecondary)),
          for (final section in lesson.sections) ...[
            AppSpacing.vLg,
            Semantics(header: true, child: Text(section.heading, style: t.titleLarge)),
            AppSpacing.vSm,
            _SectionBody(text: section.body),
          ],
          if (lesson.example != null) ...[
            AppSpacing.vLg,
            _ExampleCard(example: lesson.example!),
          ],
          AppSpacing.vLg,
          AppButton(
            label: isRead ? LearningStrings.markedRead : LearningStrings.markRead,
            icon: isRead ? Icons.check_circle : Icons.check_circle_outline,
            variant: isRead ? AppButtonVariant.tonal : AppButtonVariant.primary,
            onPressed: () => ref
                .read(learningProgressRepositoryProvider)
                .setRead(lesson.id, !isRead),
          ),
          if (next != null) ...[
            AppSpacing.vSm,
            AppButton(
              label: '${LearningStrings.nextLesson}: ${next.title}',
              variant: AppButtonVariant.text,
              onPressed: () =>
                  context.pushReplacement('${AppRoutes.lessonBase}/${next.id}'),
            ),
          ],
          AppSpacing.vMd,
          Text(LearningStrings.disclaimer, style: t.bodySmall),
          AppSpacing.vLg,
        ],
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.lesson});

  final Lesson lesson;

  static const double _height = 160;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fallback = Container(
      height: _height,
      color: c.primarySoft,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: HexPatternPainter(color: c.primary, opacity: 0.12, cell: 24),
            ),
          ),
          Container(
            width: AppDimensions.emptyIllustration,
            height: AppDimensions.emptyIllustration,
            decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
            child: Icon(lesson.topic.icon, size: AppDimensions.iconLg, color: c.primary),
          ),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: ExcludeSemantics(
        child: lesson.imageUrl == null
            ? fallback
            : Image.network(
                lesson.imageUrl!,
                height: _height,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

/// Renders paragraphs and "- " bullet lines.
class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final blocks = text.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: block.startsWith('- ')
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final line in block.split('\n'))
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.sm),
                                child: Container(
                                  width: AppSpacing.xs + 2,
                                  height: AppSpacing.xs + 2,
                                  decoration: BoxDecoration(
                                    color: c.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              AppSpacing.hSm,
                              Expanded(
                                child: Text(
                                  line.startsWith('- ') ? line.substring(2) : line,
                                  style: t.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                : Text(block, style: t.bodyMedium),
          ),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.example});

  final LessonExample example;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return AppCard(
      color: c.primarySoft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: c.primary),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(example.title, style: t.titleMedium),
                AppSpacing.vXs,
                Text(example.text, style: t.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
