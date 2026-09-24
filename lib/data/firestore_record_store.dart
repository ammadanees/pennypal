import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'record_store.dart';

/// Firestore with its built-in offline cache turned on. While offline,
/// writes land in the on-device cache immediately and are sent in order
/// when the connection returns. Records live under `users/{uid}/...` so the
/// security rules can isolate each student's data.
class FirestoreRecordStore implements RecordStore {
  FirestoreRecordStore([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    String collection,
  ) =>
      _firestore.collection('users').doc(uid).collection(collection);

  @override
  Stream<List<StoredRecord>> watch(String uid, String collection) {
    return _collection(uid, collection)
        .snapshots(includeMetadataChanges: true)
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              StoredRecord(
                id: doc.id,
                data: _fromFirestore(doc.data()),
                hasPendingWrites: doc.metadata.hasPendingWrites,
              ),
          ],
        );
  }

  @override
  Future<void> upsert(
    String uid,
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    // Do not await the server: while offline that future only completes
    // after reconnecting. The local snapshot updates straight away.
    unawaited(
      _collection(uid, collection)
          .doc(id)
          .set(_toFirestore(data), SetOptions(merge: true))
          .catchError((Object error) {
        debugPrint('Could not sync $collection/$id: $error');
      }),
    );
  }

  @override
  Future<void> delete(String uid, String collection, String id) async {
    unawaited(
      _collection(uid, collection).doc(id).delete().catchError((Object error) {
        debugPrint('Could not delete $collection/$id: $error');
      }),
    );
  }

  static Map<String, dynamic> _toFirestore(Map<String, dynamic> data) => {
        for (final entry in data.entries)
          entry.key: entry.value is DateTime
              ? Timestamp.fromDate(entry.value as DateTime)
              : entry.value,
      };

  static Map<String, dynamic> _fromFirestore(Map<String, dynamic> data) => {
        for (final entry in data.entries)
          entry.key: entry.value is Timestamp
              ? (entry.value as Timestamp).toDate()
              : entry.value,
      };
}
