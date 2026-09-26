// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/app/app.dart';
import 'package:pennypal/core/services/shared_preferences_provider.dart';
import 'package:pennypal/data/memory_record_store.dart';
import 'package:pennypal/data/record_store_provider.dart';
import 'package:pennypal/features/auth/data/auth_providers.dart';
import 'package:pennypal/features/auth/data/demo_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = DemoAuthRepository(latency: Duration.zero);
    final store = MemoryRecordStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(auth),
          recordStoreProvider.overrideWithValue(store),
        ],
        child: const PennyPalApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(PennyPalApp), findsOneWidget);
  });
}
