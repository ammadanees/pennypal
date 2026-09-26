import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/record_store.dart';
import '../../../data/record_store_provider.dart';
import '../../support/domain/support_query.dart';
import '../../learning/domain/lesson.dart';
import '../../learning/data/lessons.dart';
import '../domain/admin_feedback_entry.dart';
import '../domain/admin_student.dart';

/// Everything the admin portal reads and writes. Security rules are the
/// real gate: a student's private transactions, budgets and goals are never
/// exposed here, even to an admin account.
class AdminRepository {
  AdminRepository(this._store);

  final RecordStore _store;

  Stream<List<AdminStudent>> watchStudents() =>
      _store.watchAdminCollection('users').map((records) {
        final list = records
            .where((r) => r.data['role'] != 'admin')
            .map(AdminStudent.fromRecord)
            .toList()
          ..sort((a, b) {
            final an = a.createdAt;
            final bn = b.createdAt;
            if (an == null || bn == null) return 0;
            return bn.compareTo(an);
          });
        return list;
      });

  Stream<List<SupportQuery>> watchAllSupportQueries() =>
      _store.watchAdminCollection('supportQueries').map((records) {
        final list = records.map(SupportQuery.fromRecord).toList()
          ..sort((a, b) => b.submittedOn.compareTo(a.submittedOn));
        return list;
      });

  Future<void> replyToQuery(String id, String response) =>
      _store.updateAdminDoc('supportQueries', id, {
        'adminResponse': response.trim(),
        'status': SupportStatus.answered.name,
      });

  Future<void> setQueryStatus(String id, SupportStatus status) =>
      _store.updateAdminDoc('supportQueries', id, {'status': status.name});

  Stream<List<AdminFeedbackEntry>> watchAllFeedback() =>
      _store.watchAdminCollection('feedback').map((records) {
        final list = records.map(AdminFeedbackEntry.fromRecord).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Stream<List<Lesson>> watchLearningContent() =>
      _store.watchAdminCollection('learningContent').map((records) {
        if (records.isEmpty) return bundledLessons;
        return records.map(Lesson.fromRecord).toList();
      });

  Future<void> saveLesson(Lesson lesson) =>
      _store.updateAdminDoc('learningContent', lesson.id, lesson.toMap());

  Future<void> deleteLesson(String id) =>
      _store.delete('', 'learningContent', id);
}

final adminRepositoryProvider =
    Provider<AdminRepository>((ref) => AdminRepository(ref.watch(recordStoreProvider)));

final adminStudentsProvider =
    StreamProvider<List<AdminStudent>>((ref) => ref.watch(adminRepositoryProvider).watchStudents());

final adminSupportQueriesProvider = StreamProvider<List<SupportQuery>>(
  (ref) => ref.watch(adminRepositoryProvider).watchAllSupportQueries(),
);

final adminFeedbackProvider = StreamProvider<List<AdminFeedbackEntry>>(
  (ref) => ref.watch(adminRepositoryProvider).watchAllFeedback(),
);

final adminLessonsProvider = StreamProvider<List<Lesson>>(
  (ref) => ref.watch(adminRepositoryProvider).watchLearningContent(),
);

