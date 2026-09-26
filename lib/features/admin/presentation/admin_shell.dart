import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/admin_strings.dart';
import '../../../core/responsive/adaptive_scaffold.dart';

/// Admin navigation: Dashboard, Users, Support, Feedback. Same shell
/// component as the student app, so the admin portal shares one design
/// system with a denser layout.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    AdaptiveDestination(
      label: AdminStrings.tabDashboard,
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    AdaptiveDestination(
      label: AdminStrings.tabUsers,
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    AdaptiveDestination(
      label: AdminStrings.tabContent,
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
    ),
    AdaptiveDestination(
      label: AdminStrings.tabSupport,
      icon: Icons.support_agent_outlined,
      selectedIcon: Icons.support_agent,
    ),
    AdaptiveDestination(
      label: AdminStrings.tabFeedback,
      icon: Icons.favorite_outline,
      selectedIcon: Icons.favorite,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      destinations: _destinations,
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      body: navigationShell,
    );
  }
}
