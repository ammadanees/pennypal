import 'dart:async';

import 'record_store.dart';

/// In-memory store used by debug demo mode and by tests.
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
}
