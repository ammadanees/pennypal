import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/admin_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../data/admin_repository.dart';
import '../domain/admin_student.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AdminStrings.tabUsers,
      body: Column(
        children: [
          AppSpacing.vSm,
          AppTextField(
            label: 'Search students',
            controller: _search,
            prefixIcon: Icons.search,
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
          ),
          AppSpacing.vSm,
          Expanded(
            child: AsyncValueView<List<AdminStudent>>(
              value: ref.watch(adminStudentsProvider),
              onRetry: () => ref.invalidate(adminStudentsProvider),
              isEmpty: (list) => list.isEmpty,
              empty: const AppEmptyState(
                icon: Icons.people_outline,
                title: AdminStrings.noStudentsTitle,
                message: AdminStrings.noStudentsMessage,
              ),
              data: (list) {
                final filtered = _query.isEmpty
                    ? list
                    : list
                        .where((s) =>
                            s.fullName.toLowerCase().contains(_query) ||
                            s.email.toLowerCase().contains(_query))
                        .toList();
                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.search_off,
                    title: AdminStrings.noStudentsTitle,
                    message: AdminStrings.noStudentsMessage,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppDimensions.bottomNavClearance),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => AppSpacing.vSm,
                  itemBuilder: (context, i) => _StudentCard(student: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});

  final AdminStudent student;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return AppCard(
      child: Row(
        children: [
          Container(
            width: AppDimensions.avatar,
            height: AppDimensions.avatar,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
            child: Text(
              student.fullName.isEmpty ? '?' : student.fullName[0].toUpperCase(),
              style: t.titleLarge?.copyWith(color: c.primary),
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName, style: t.titleMedium),
                Text(student.email, style: t.bodySmall),
                if (student.mobile.isNotEmpty)
                  Text(student.mobile, style: t.bodySmall),
                AppSpacing.vXs,
                Text(
                  '${AdminStrings.joined}: '
                  '${student.createdAt == null ? AdminStrings.notAvailable : Formatters.shortDate(student.createdAt!)}'
                  '  \u00b7  ${AdminStrings.lastActive}: '
                  '${student.lastLogin == null ? AdminStrings.notAvailable : Formatters.relativeTime(student.lastLogin!)}',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
