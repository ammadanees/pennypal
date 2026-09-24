import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/presentation/auth_controller.dart';

/// Landing page for administrators until the admin portal is built.
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    return AppScaffold(
      title: 'Admin portal',
      actions: [
        IconButton(
          tooltip: AppStrings.profileTitle,
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.push(AppRoutes.profile),
        ),
      ],
      body: AppEmptyState(
        icon: Icons.admin_panel_settings_outlined,
        title: 'Signed in as ${user?.email ?? 'admin'}',
        message: 'User, content and support tools will appear here.',
        actionLabel: AppStrings.signOut,
        onAction: () => ref.read(authControllerProvider.notifier).signOut(),
      ),
    );
  }
}
