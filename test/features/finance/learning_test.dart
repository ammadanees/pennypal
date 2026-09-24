import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/data/memory_record_store.dart';
import 'package:pennypal/features/learning/data/learning_progress_repository.dart';
import 'package:pennypal/features/learning/data/lessons.dart';
import 'package:pennypal/features/learning/domain/lesson.dart';

void main() {
  test('lesson ids are unique and content is complete', () {
    final ids = bundledLessons.map((l) => l.id).toSet();
    expect(ids, hasLength(bundledLessons.length));
    for (final lesson in bundledLessons) {
      expect(lesson.title.trim(), isNotEmpty);
      expect(lesson.summary.trim(), isNotEmpty);
      expect(lesson.readMinutes, greaterThan(0));
      expect(lesson.sections, isNotEmpty);
      for (final s in lesson.sections) {
        expect(s.heading.trim(), isNotEmpty);
        expect(s.body.trim(), isNotEmpty);
      }
    }
  });

  test('every SRS topic has at least one lesson', () {
    for (final topic in LearningTopic.values) {
      expect(bundledLessons.any((l) => l.topic == topic), isTrue, reason: topic.label);
    }
  });

  test('marking a lesson read and unread', () async {
    final repo = LearningProgressRepository(MemoryRecordStore(), 'u1');
    await repo.setRead('what-is-a-budget', true);
    await repo.setRead('what-is-a-budget', true); // no duplicate
    expect(await repo.watchRead().first, {'what-is-a-budget'});
    await repo.setRead('what-is-a-budget', false);
    expect(await repo.watchRead().first, isEmpty);
  });

  test('progress is kept per student', () async {
    final store = MemoryRecordStore();
    await LearningProgressRepository(store, 'u1').setRead('fifty-thirty-twenty', true);
    expect(await LearningProgressRepository(store, 'u2').watchRead().first, isEmpty);
  });
}
