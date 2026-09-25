import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/id_generator.dart';
import '../../../data/record_store.dart';
import '../../../data/record_store_provider.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/support_query.dart';

/// Feedback and support queries. Both live in top-level collections so
/// admins can read them; rules let a student read only their own.
class SupportRepository {
  SupportRepository(this._store, this._uid);

  final RecordStore _store;
  final String _uid;

  Stream<List<SupportQuery>> watchMine() =>
      _store.watchShared('supportQueries', userId: _uid).map((records) {
        final list = records.map(SupportQuery.fromRecord).toList()
          ..sort((a, b) => b.submittedOn.compareTo(a.submittedOn));
        return list;
      });

  Future<void> submitQuery({required String subject, required String message}) =>
      _store.upsertShared('supportQueries', IdGenerator.next(), {
        'userId': _uid,
        'subject': subject.trim(),
        'message': message.trim(),
        'status': SupportStatus.open.name,
        'submittedOn': DateTime.now(),
      });

  Future<void> submitFeedback({
    required String name,
    required String email,
    required int rating,
    required String comments,
  }) =>
      _store.upsertShared('feedback', IdGenerator.next(), {
        'userId': _uid,
        'name': name.trim(),
        'email': email.trim(),
        'rating': rating,
        'comments': comments.trim(),
        'createdAt': DateTime.now(),
      });
}

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepository(
    ref.watch(recordStoreProvider),
    ref.watch(currentUidProvider) ?? '',
  ),
);

final supportQueriesProvider = StreamProvider<List<SupportQuery>>((ref) {
  if (ref.watch(currentUidProvider) == null) {
    return Stream.value(const <SupportQuery>[]);
  }
  return ref.watch(supportRepositoryProvider).watchMine();
});
