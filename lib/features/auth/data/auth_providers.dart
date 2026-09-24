import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// Overridden in main() with the Firebase (or debug demo) implementation.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError('authRepositoryProvider not overridden'),
);

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// The signed-in user's id, or null when signed out.
final currentUidProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider.select((state) => state.valueOrNull?.uid)),
);
