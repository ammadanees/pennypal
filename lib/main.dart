import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/config/dev_tools.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/shared_preferences_provider.dart';
import 'data/demo_seed.dart';
import 'data/firestore_record_store.dart';
import 'data/memory_record_store.dart';
import 'data/record_store.dart';
import 'data/record_store_provider.dart';
import 'features/auth/data/auth_providers.dart';
import 'features/auth/data/demo_auth_repository.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  FirebaseAuthRepository.loadPersistedVerifiedUids(prefs);
  await LocalNotificationService.initialize();
  final backend = await _createBackend(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(backend.auth),
        recordStoreProvider.overrideWithValue(backend.store),
      ],
      // Providers sit above DevicePreview so app state survives device changes.
      child: DevicePreview(
        enabled: devicePreviewEnabled,
        builder: (context) => const PennyPalApp(),
      ),
    ),
  );
}

class _Backend {
  const _Backend(this.auth, this.store);

  final AuthRepository auth;
  final RecordStore store;
}

/// Uses Firebase when it is configured. In debug builds only, falls back to
/// an in-memory demo (with sample data for the demo student) so the app can
/// run before Firebase is set up. A release build with broken Firebase
/// configuration fails loudly instead.
Future<_Backend> _createBackend(SharedPreferences prefs) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Keep an on-device copy so expenses can be entered offline. Changes are
    // sent to the cloud automatically once a connection is back.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    return _Backend(FirebaseAuthRepository(prefs: prefs), FirestoreRecordStore());
  } catch (error) {
    if (kReleaseMode) rethrow;
    debugPrint('Firebase is not configured ($error). Running in demo mode.');
    final store = MemoryRecordStore();
    await seedDemoData(store);
    return _Backend(DemoAuthRepository(), store);
  }
}
