import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../notifications/data/notification_repository.dart';
import '../../transactions/presentation/transaction_filter_controller.dart';

import '../../../core/responsive/adaptive_scaffold.dart';

/// Signed-in student navigation: bottom bar, rail or sidebar by screen size.
/// Each tab keeps its own navigation state.
class StudentShell extends ConsumerWidget {
  const StudentShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    AdaptiveDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    AdaptiveDestination(
      label: 'Activity',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
    AdaptiveDestination(
      label: 'Budget',
      icon: Icons.pie_chart_outline,
      selectedIcon: Icons.pie_chart,
    ),
    AdaptiveDestination(
      label: 'Savings',
      icon: Icons.savings_outlined,
      selectedIcon: Icons.savings,
    ),
    AdaptiveDestination(
      label: 'More',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationEngineProvider);
    return AdaptiveScaffold(
      destinations: _destinations,
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) {
        // If navigating to Activity (or leaving it), reset drill-down filters to default "All"
        if (index == 1 || (navigationShell.currentIndex == 1 && index != 1)) {
          ref.read(transactionFilterProvider.notifier).clear();
        }
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      body: navigationShell,
    );
  }
}
