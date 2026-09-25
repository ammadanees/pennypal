import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/admin_strings.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/accent_icon_box.dart';
import '../../../shared/widgets/adaptive_grid.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/insight_banner.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../support/domain/support_query.dart';
import '../data/admin_repository.dart';
import '../domain/admin_student.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(authStateProvider).valueOrNull;
    final students = ref.watch(adminStudentsProvider);
    final queries = ref.watch(adminSupportQueriesProvider);
    final feedback = ref.watch(adminFeedbackProvider);

    final openCount =
        queries.valueOrNull?.where((q) => q.status == SupportStatus.open).length;
    final feedbackList = feedback.valueOrNull;
    final avgRating = (feedbackList == null || feedbackList.isEmpty)
        ? null
        : feedbackList.fold<int>(0, (s, f) => s + f.rating) / feedbackList.length;

    return AppScaffold(
      title: AdminStrings.portalTitle,
      actions: [
        IconButton(
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout),
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          Text('Signed in as ${admin?.fullName ?? 'Admin'}',
              style: context.text.headlineMedium),
          AppSpacing.vMd,
          const InsightBanner(
            message: AdminStrings.privacyNote,
            accent: AppAccents.blue,
            icon: Icons.shield_outlined,
          ),
          AppSpacing.vMd,
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 4 : 2;
              return AdaptiveGrid(
                columns: columns,
                children: [
                  _StatCard(
                    icon: Icons.people_outline,
                    accent: AppAccents.blue,
                    label: AdminStrings.totalStudents,
                    value: students.valueOrNull?.length.toString(),
                    onTap: () => context.go(AppRoutes.adminUsers),
                  ),
                  _StatCard(
                    icon: Icons.support_agent_outlined,
                    accent: AppAccents.coral,
                    label: AdminStrings.openQueries,
                    value: openCount?.toString(),
                    onTap: () => context.go(AppRoutes.adminSupport),
                  ),
                  _StatCard(
                    icon: Icons.star_outline,
                    accent: AppAccents.amber,
                    label: AdminStrings.avgRating,
                    value: avgRating == null ? null : avgRating.toStringAsFixed(1),
                    onTap: () => context.go(AppRoutes.adminFeedback),
                  ),
                  _StatCard(
                    icon: Icons.favorite_outline,
                    accent: AppAccents.pink,
                    label: AdminStrings.feedbackCount,
                    value: feedbackList?.length.toString(),
                    onTap: () => context.go(AppRoutes.adminFeedback),
                  ),
                ],
              );
            },
          ),
          const SectionHeader(title: AdminStrings.recentSignups),
          students.when(
            loading: () => const AppLoading(rows: 3),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: list.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(AdminStrings.noStudentsMessage),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < list.take(5).length; i++) ...[
                          if (i > 0) const Divider(),
                          _StudentRow(student: list[i]),
                        ],
                      ],
                    ),
            ),
          ),
          AppSpacing.vLg,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final AppAccent accent;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccentIconBox(icon: icon, accent: accent, size: 40),
          AppSpacing.vMd,
          Text(
            value ?? '-',
            style: context.text.headlineMedium,
          ),
          Text(label, style: context.text.bodySmall),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student});

  final AdminStudent student;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: AppDimensions.leadingIcon,
            height: AppDimensions.leadingIcon,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
            child: Text(
              student.fullName.isEmpty ? '?' : student.fullName[0].toUpperCase(),
              style: t.titleMedium?.copyWith(color: c.primary),
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName, style: t.titleMedium),
                Text(student.email, style: t.bodySmall),
              ],
            ),
          ),
          Text(
            student.createdAt == null
                ? AdminStrings.notAvailable
                : Formatters.relativeTime(student.createdAt),
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}
