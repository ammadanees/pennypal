import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/admin_strings.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../support/domain/support_query.dart';
import '../data/admin_repository.dart';

class AdminSupportScreen extends ConsumerStatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  ConsumerState<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends ConsumerState<AdminSupportScreen> {
  SupportStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AdminStrings.tabSupport,
      body: Column(
        children: [
          AppSpacing.vSm,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AppChip(
                  label: 'All',
                  selected: _filter == null,
                  onSelected: () => setState(() => _filter = null),
                ),
                for (final status in SupportStatus.values) ...[
                  AppSpacing.hSm,
                  AppChip(
                    label: switch (status) {
                      SupportStatus.open => 'Open',
                      SupportStatus.answered => 'Answered',
                      SupportStatus.closed => 'Closed',
                    },
                    selected: _filter == status,
                    onSelected: () => setState(
                      () => _filter = _filter == status ? null : status,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.vSm,
          Expanded(
            child: AsyncValueView<List<SupportQuery>>(
              value: ref.watch(adminSupportQueriesProvider),
              onRetry: () => ref.invalidate(adminSupportQueriesProvider),
              isEmpty: (list) => list.isEmpty,
              empty: const AppEmptyState(
                icon: Icons.support_agent_outlined,
                title: AdminStrings.noQueriesTitle,
                message: AdminStrings.noQueriesMessage,
              ),
              data: (list) {
                final filtered =
                    _filter == null ? list : list.where((q) => q.status == _filter).toList();
                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.support_agent_outlined,
                    title: AdminStrings.noQueriesTitle,
                    message: AdminStrings.noQueriesMessage,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppDimensions.bottomNavClearance),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => AppSpacing.vSm,
                  itemBuilder: (context, i) => _QueryCard(query: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QueryCard extends ConsumerStatefulWidget {
  const _QueryCard({required this.query});

  final SupportQuery query;

  @override
  ConsumerState<_QueryCard> createState() => _QueryCardState();
}

class _QueryCardState extends ConsumerState<_QueryCard> {
  late final _reply = TextEditingController(text: widget.query.adminResponse ?? '');
  bool _sending = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_reply.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(adminRepositoryProvider).replyToQuery(widget.query.id, _reply.text);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(AdminStrings.replySent)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleClosed() async {
    final next =
        widget.query.status == SupportStatus.closed ? SupportStatus.answered : SupportStatus.closed;
    await ref.read(adminRepositoryProvider).setQueryStatus(widget.query.id, next);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AdminStrings.statusUpdated)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.query;
    final c = context.colors;
    final t = context.text;
    final (String label, AppAccent accent) = switch (q.status) {
      SupportStatus.open => ('Open', AppAccents.amber),
      SupportStatus.answered => ('Answered', AppAccents.green),
      SupportStatus.closed => ('Closed', AppAccents.slate),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(q.subject, style: t.titleMedium)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
                decoration: BoxDecoration(color: accent.color, borderRadius: AppRadius.pillAll),
                child: Text(label,
                    style: t.labelSmall?.copyWith(color: accent.onColor, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          Text(Formatters.relativeTime(q.submittedOn), style: t.bodySmall),
          AppSpacing.vSm,
          Text(q.message, style: t.bodyMedium),
          AppSpacing.vMd,
          AppTextField(
            label: AdminStrings.replyLabel,
            controller: _reply,
            maxLines: 3,
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: AdminStrings.sendReply,
                  icon: Icons.send_outlined,
                  isLoading: _sending,
                  onPressed: _send,
                ),
              ),
              AppSpacing.hSm,
              AppButton(
                label: q.status == SupportStatus.closed
                    ? AdminStrings.reopen
                    : AdminStrings.markClosed,
                variant: AppButtonVariant.outlined,
                expand: false,
                onPressed: _toggleClosed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
