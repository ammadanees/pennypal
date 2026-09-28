import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'record_store.dart';

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

  @override
  Stream<List<StoredRecord>> watchShared(String collection,
      {required String userId}) {
    return _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
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
  Future<void> upsertShared(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    unawaited(
      _firestore
          .collection(collection)
          .doc(id)
          .set(_toFirestore(data), SetOptions(merge: true))
          .catchError((Object error) {
        debugPrint('Could not sync $collection/$id: $error');
      }),
    );
  }

  @override
  Stream<List<StoredRecord>> watchAdminCollection(String collection) {
    return _firestore
        .collection(collection)
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
  Future<void> updateAdminDoc(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    unawaited(
      _firestore
          .collection(collection)
          .doc(id)
          .set(_toFirestore(data), SetOptions(merge: true))
          .catchError((Object error) {
        debugPrint('Could not update $collection/$id: $error');
      }),
    );
  }

  @override
  Future<StoredRecord?> getUserProfile(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    final data = snap.data();
    return data == null
        ? null
        : StoredRecord(id: uid, data: _fromFirestore(data));
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
