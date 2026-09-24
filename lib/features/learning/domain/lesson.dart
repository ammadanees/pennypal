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
}
