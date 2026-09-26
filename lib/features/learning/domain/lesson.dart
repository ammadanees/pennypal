import 'package:flutter/material.dart';

enum LearningTopic {
  budgeting('Budgeting', Icons.pie_chart_outline),
  saving('Saving', Icons.savings_outlined),
  income('Income', Icons.south_west),
  necessary('Necessary expenses', Icons.home_outlined),
  needsVsWants('Needs vs wants', Icons.compare_arrows),
  optional('Optional expenses', Icons.local_cafe_outlined);

  const LearningTopic(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum LessonLevel {
  beginner('Beginner'),
  intermediate('Intermediate');

  const LessonLevel(this.label);

  final String label;
}

class LessonSection {
  const LessonSection(this.heading, this.body);

  final String heading;

  /// Paragraphs are separated by a blank line. Lines starting with "- "
  /// are shown as bullets.
  final String body;
}

class LessonExample {
  const LessonExample(this.title, this.text);

  final String title;
  final String text;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.topic,
    required this.level,
    required this.summary,
    required this.readMinutes,
    required this.sections,
    this.example,
    this.imageUrl,
  });

  final String id;
  final String title;
  final LearningTopic topic;
  final LessonLevel level;
  final String summary;
  final int readMinutes;
  final List<LessonSection> sections;
  final LessonExample? example;

  /// Optional hosted image (for example a Cloudinary URL). Lessons without
  /// one show a topic illustration instead.
  final String? imageUrl;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'topic': topic.name,
        'level': level.name,
        'summary': summary,
        'readMinutes': readMinutes,
        'sections': [
          for (final s in sections) {'heading': s.heading, 'body': s.body},
        ],
        if (example != null)
          'example': {'title': example!.title, 'text': example!.text},
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  factory Lesson.fromRecord(dynamic record) {
    final d = record is Map<String, dynamic>
        ? record
        : (record.data as Map<String, dynamic>);
    final id = (record is Map<String, dynamic> ? record['id'] : record.id) as String? ?? '';
    final topicStr = d['topic'] as String?;
    final levelStr = d['level'] as String?;
    final sectionsRaw = d['sections'] as List? ?? [];
    final exampleRaw = d['example'] as Map?;

    return Lesson(
      id: id,
      title: (d['title'] as String?) ?? 'Untitled Lesson',
      topic: LearningTopic.values.firstWhere(
        (t) => t.name == topicStr,
        orElse: () => LearningTopic.budgeting,
      ),
      level: LessonLevel.values.firstWhere(
        (l) => l.name == levelStr,
        orElse: () => LessonLevel.beginner,
      ),
      summary: (d['summary'] as String?) ?? '',
      readMinutes: (d['readMinutes'] as num?)?.toInt() ?? 3,
      sections: [
        for (final s in sectionsRaw)
          if (s is Map)
            LessonSection(
              (s['heading'] as String?) ?? '',
              (s['body'] as String?) ?? '',
            ),
      ],
      example: exampleRaw != null
          ? LessonExample(
              (exampleRaw['title'] as String?) ?? '',
              (exampleRaw['text'] as String?) ?? '',
            )
          : null,
      imageUrl: d['imageUrl'] as String?,
    );
  }
}

