import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'record_store.dart';

/// Overridden in main() with Firestore, or the in-memory demo store.
final recordStoreProvider = Provider<RecordStore>(
  (ref) => throw UnimplementedError('recordStoreProvider not overridden'),
);
