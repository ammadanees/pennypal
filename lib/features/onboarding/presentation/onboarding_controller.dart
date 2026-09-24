import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_preferences_provider.dart';

/// Whether the first-launch welcome screens have been completed.
final onboardingSeenProvider =
    NotifierProvider<OnboardingSeenNotifier, bool>(OnboardingSeenNotifier.new);

class OnboardingSeenNotifier extends Notifier<bool> {
  static const _key = 'onboarding_seen';

  @override
  bool build() => ref.read(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> markSeen() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
  }
}
