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

abstract class RecordStore {
  Stream<List<StoredRecord>> watch(String uid, String collection);

  Future<void> upsert(
    String uid,
    String collection,
    String id,
    Map<String, dynamic> data,
  );

  Future<void> delete(String uid, String collection, String id);

  Stream<List<StoredRecord>> watchShared(String collection,
      {required String userId});

  Future<void> upsertShared(
    String collection,
    String id,
    Map<String, dynamic> data,
  );

  Stream<List<StoredRecord>> watchAdminCollection(String collection);

  Future<void> updateAdminDoc(
    String collection,
    String id,
    Map<String, dynamic> data,
  );

  Future<StoredRecord?> getUserProfile(String uid);
}
