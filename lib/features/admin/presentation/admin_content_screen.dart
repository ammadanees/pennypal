import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/id_generator.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../learning/domain/lesson.dart';
import '../data/admin_repository.dart';

class AdminContentScreen extends ConsumerStatefulWidget {
  const AdminContentScreen({super.key});

  @override
  ConsumerState<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends ConsumerState<AdminContentScreen> {
  LearningTopic? _selectedTopic;

  Future<void> _openLessonEditor([Lesson? existing]) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final summaryCtrl = TextEditingController(text: existing?.summary ?? '');
    final sectionHeadingCtrl = TextEditingController(
      text: existing?.sections.firstOrNull?.heading ?? 'Key Concept',
    );
    final sectionBodyCtrl = TextEditingController(
      text: existing?.sections.firstOrNull?.body ?? '',
    );
    final exampleTitleCtrl = TextEditingController(
      text: existing?.example?.title ?? 'Practical Example',
    );
    final exampleTextCtrl = TextEditingController(
      text: existing?.example?.text ?? '',
    );
    var topic = existing?.topic ?? LearningTopic.budgeting;
    var level = existing?.level ?? LessonLevel.beginner;
    var readMinutes = existing?.readMinutes ?? 3;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.paddingOf(ctx).bottom,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  existing == null ? 'Add Learning Content' : 'Edit Learning Content',
                  style: ctx.text.titleLarge,
                ),
                AppSpacing.vMd,
                AppTextField(
                  label: 'Lesson Title',
                  controller: titleCtrl,
                  prefixIcon: Icons.title,
                ),
                AppSpacing.vMd,
                Text('Topic', style: ctx.text.labelLarge),
                AppSpacing.vXs,
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final t in LearningTopic.values)
                      AppChip(
                        label: t.label,
                        icon: t.icon,
                        selected: topic == t,
                        onSelected: () => setModalState(() => topic = t),
                      ),
                  ],
                ),
                AppSpacing.vMd,
                Text('Difficulty Level', style: ctx.text.labelLarge),
                AppSpacing.vXs,
                SegmentedButton<LessonLevel>(
                  segments: const [
                    ButtonSegment(
                      value: LessonLevel.beginner,
                      label: Text('Beginner'),
                    ),
                    ButtonSegment(
                      value: LessonLevel.intermediate,
                      label: Text('Intermediate'),
                    ),
                  ],
                  selected: {level},
                  onSelectionChanged: (s) => setModalState(() => level = s.first),
                ),
                AppSpacing.vMd,
                AppTextField(
                  label: 'Summary',
                  controller: summaryCtrl,
                  prefixIcon: Icons.short_text,
                  maxLines: 2,
                ),
                AppSpacing.vMd,
                AppTextField(
                  label: 'Main Section Heading',
                  controller: sectionHeadingCtrl,
                  prefixIcon: Icons.notes,
                ),
                AppSpacing.vMd,
                AppTextField(
                  label: 'Lesson Content / Body',
                  controller: sectionBodyCtrl,
                  prefixIcon: Icons.article_outlined,
                  maxLines: 4,
                ),
                AppSpacing.vMd,
                AppTextField(
                  label: 'Example Title',
                  controller: exampleTitleCtrl,
                  prefixIcon: Icons.lightbulb_outline,
                ),
                AppSpacing.vMd,
                AppTextField(
                  label: 'Example Explanation',
                  controller: exampleTextCtrl,
                  prefixIcon: Icons.help_outline,
                  maxLines: 2,
                ),
                AppSpacing.vLg,
                AppButton(
                  label: existing == null ? 'Publish Lesson' : 'Save Changes',
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty || sectionBodyCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Title and content body are required.')),
                      );
                      return;
                    }
                    final lesson = Lesson(
                      id: existing?.id ?? IdGenerator.next(),
                      title: titleCtrl.text.trim(),
                      topic: topic,
                      level: level,
                      summary: summaryCtrl.text.trim().isNotEmpty
                          ? summaryCtrl.text.trim()
                          : 'Educational guide on ${topic.label}',
                      readMinutes: readMinutes,
                      sections: [
                        LessonSection(
                          sectionHeadingCtrl.text.trim().isNotEmpty
                              ? sectionHeadingCtrl.text.trim()
                              : 'Core Topic',
                          sectionBodyCtrl.text.trim(),
                        ),
                      ],
                      example: exampleTextCtrl.text.trim().isNotEmpty
                          ? LessonExample(
                              exampleTitleCtrl.text.trim().isNotEmpty
                                  ? exampleTitleCtrl.text.trim()
                                  : 'Example',
                              exampleTextCtrl.text.trim(),
                            )
                          : null,
                    );
                    ref.read(adminRepositoryProvider).saveLesson(lesson);
                    Navigator.of(ctx).pop(true);
                  },
                ),
                AppSpacing.vMd,
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existing == null ? 'Lesson published successfully!' : 'Lesson updated successfully!'),
        ),
      );
    }
  }

  Future<void> _deleteLesson(Lesson lesson) async {
    final ok = await confirmAction(
      context,
      title: 'Delete Lesson',
      message: 'Are you sure you want to remove "${lesson.title}" from the Learning Hub?',
      confirmLabel: 'Delete',
    );
    if (!ok || !mounted) return;
    await ref.read(adminRepositoryProvider).deleteLesson(lesson.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson deleted from learning content.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    return AppScaffold(
      title: 'Learning Content',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLessonEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add Lesson'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSpacing.vSm,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AppChip(
                  label: 'All Topics',
                  selected: _selectedTopic == null,
                  onSelected: () => setState(() => _selectedTopic = null),
                ),
                for (final topic in LearningTopic.values) ...[
                  AppSpacing.hXs,
                  AppChip(
                    label: topic.label,
                    icon: topic.icon,
                    selected: _selectedTopic == topic,
                    onSelected: () => setState(() => _selectedTopic = topic),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.vMd,
          Expanded(
            child: AsyncValueView<List<Lesson>>(
              value: ref.watch(adminLessonsProvider),
              onRetry: () => ref.invalidate(adminLessonsProvider),
              data: (lessons) {
                final filtered = _selectedTopic == null
                    ? lessons
                    : lessons.where((l) => l.topic == _selectedTopic).toList();

                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.menu_book_outlined,
                    title: 'No Learning Content',
                    message: 'No lessons found for this topic. Tap "Add Lesson" to publish one.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppDimensions.fabClearance),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => AppSpacing.vSm,
                  itemBuilder: (ctx, i) {
                    final item = filtered[i];
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(item.topic.icon, color: c.primary, size: 20),
                              AppSpacing.hSm,
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: t.titleMedium,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: 'Edit',
                                onPressed: () => _openLessonEditor(item),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 20, color: c.error),
                                tooltip: 'Delete',
                                onPressed: () => _deleteLesson(item),
                              ),
                            ],
                          ),
                          AppSpacing.vXs,
                          Text(item.summary, style: t.bodySmall),
                          AppSpacing.vSm,
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: c.surfaceElevated,
                                  borderRadius: AppRadius.pillAll,
                                ),
                                child: Text(
                                  item.topic.label,
                                  style: t.bodySmall?.copyWith(fontSize: 11),
                                ),
                              ),
                              AppSpacing.hSm,
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: c.primarySoft,
                                  borderRadius: AppRadius.pillAll,
                                ),
                                child: Text(
                                  item.level.label,
                                  style: t.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: c.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              AppSpacing.hSm,
                              Text(
                                '${item.readMinutes} min read',
                                style: t.bodySmall?.copyWith(color: c.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
