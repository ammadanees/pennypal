/// One saved document: its id, its fields (dates as DateTime) and whether
/// it still has changes waiting to reach the cloud.
class StoredRecord {
  const StoredRecord({
    required this.id,
    required this.data,
    this.hasPendingWrites = false,
  });

  final String id;
  final Map<String, dynamic> data;
  final bool hasPendingWrites;
}

/// Per-student storage for transactions, budgets and savings goals.
///
/// Reads are live streams that always come from the on-device copy first.
/// Writes return as soon as they are saved on the device; the cloud copy
/// catches up on its own when a connection is available.
abstract class RecordStore {
  Stream<List<StoredRecord>> watch(String uid, String collection);

  /// Creates or updates. Saving the same id twice never creates a duplicate.
  Future<void> upsert(
    String uid,
    String collection,
    String id,
    Map<String, dynamic> data,
  );

  Future<void> delete(String uid, String collection, String id);

  /// A student's own records in a top-level collection that admins can also
  /// read (support queries, feedback).
  Stream<List<StoredRecord>> watchShared(String collection, {required String userId});

  Future<void> upsertShared(
    String collection,
    String id,
    Map<String, dynamic> data,
  );

  /// Every document in a top-level collection, unfiltered. Used only by the
  /// admin portal; Firestore security rules are the real gate on who this
  /// actually returns data for.
  Stream<List<StoredRecord>> watchAdminCollection(String collection);

  Future<void> updateAdminDoc(
    String collection,
    String id,
    Map<String, dynamic> data,
  );

  /// A single user's top-level profile document (`users/{uid}`), separate
  /// from that student's private subcollections.
  Future<StoredRecord?> getUserProfile(String uid);
}
