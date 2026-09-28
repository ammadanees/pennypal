import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/record_store.dart';
import '../../../data/record_store_provider.dart';
import '../../auth/data/auth_providers.dart';

class LearningProgressRepository {
  LearningProgressRepository(this._store, this._uid);

  static const _collection = 'learningProgress';

  final RecordStore _store;
  final String _uid;

  Stream<Set<String>> watchRead() => _store
      .watch(_uid, _collection)
      .map((records) => {for (final r in records) r.id});

  Future<void> setRead(String lessonId, bool read) => read
      ? _store.upsert(_uid, _collection, lessonId, {'readAt': DateTime.now()})
      : _store.delete(_uid, _collection, lessonId);
}

final learningProgressRepositoryProvider = Provider<LearningProgressRepository>(
  (ref) => LearningProgressRepository(
    ref.watch(recordStoreProvider),
    ref.watch(currentUidProvider) ?? '',
  ),
);

final readLessonsProvider = StreamProvider<Set<String>>((ref) {
  if (ref.watch(currentUidProvider) == null) {
    return Stream.value(const <String>{});
  }
  return ref.watch(learningProgressRepositoryProvider).watchRead();
});
