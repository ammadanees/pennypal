import 'dart:async';

import 'record_store.dart';

class MemoryRecordStore implements RecordStore {
  final Map<String, Map<String, Map<String, dynamic>>> _data = {};
  final Map<String, StreamController<List<StoredRecord>>> _controllers = {};

  String _key(String uid, String collection) => '$uid|$collection';

  StreamController<List<StoredRecord>> _controller(String key) =>
      _controllers.putIfAbsent(
        key,
        () => StreamController<List<StoredRecord>>.broadcast(),
      );

  List<StoredRecord> _snapshot(String key) => [
        for (final entry in (_data[key] ?? const {}).entries)
          StoredRecord(id: entry.key, data: Map.of(entry.value)),
      ];

  void _emit(String key) => _controller(key).add(_snapshot(key));

  @override
  Stream<List<StoredRecord>> watch(String uid, String collection) async* {
    final key = _key(uid, collection);
    yield _snapshot(key);
    yield* _controller(key).stream;
  }

  @override
  Future<void> upsert(
    String uid,
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final key = _key(uid, collection);
    final docs = _data.putIfAbsent(key, () => {});
    docs[id] = {...?docs[id], ...data};
    _emit(key);
  }

  @override
  Future<void> delete(String uid, String collection, String id) async {
    final key = _key(uid, collection);
    _data[key]?.remove(id);
    _emit(key);
  }

  @override
  Stream<List<StoredRecord>> watchShared(String collection,
      {required String userId}) async* {
    List<StoredRecord> mine() => [
          for (final r in _snapshot(_sharedKey(collection)))
            if (r.data['userId'] == userId) r,
        ];
    yield mine();
    yield* _controller(_sharedKey(collection)).stream.map((_) => mine());
  }

  @override
  Future<void> upsertShared(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final key = _sharedKey(collection);
    final docs = _data.putIfAbsent(key, () => {});
    docs[id] = {...?docs[id], ...data};
    _emit(key);
  }

  String _sharedKey(String collection) => '_shared|$collection';

  @override
  Stream<List<StoredRecord>> watchAdminCollection(String collection) async* {
    final key = _sharedKey(collection);
    yield _snapshot(key);
    yield* _controller(key).stream;
  }

  @override
  Future<void> updateAdminDoc(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) =>
      upsertShared(collection, id, data);

  @override
  Future<StoredRecord?> getUserProfile(String uid) async {
    final doc = _data[_sharedKey('users')]?[uid];
    return doc == null ? null : StoredRecord(id: uid, data: Map.of(doc));
  }

  Future<void> seedUserProfile(String uid, Map<String, dynamic> data) =>
      upsertShared('users', uid, data);
}
