import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/step5_strings.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/accent_icon_box.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../data/notification_repository.dart';
import '../domain/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    return AppScaffold(
      title: Step5Strings.notificationsTitle,
      actions: [
        if (unread > 0)
          AppButton(
            label: Step5Strings.markAllRead,
            variant: AppButtonVariant.text,
            expand: false,
            onPressed: () => ref
                .read(notificationRepositoryProvider)
                .markAllRead(notifications.valueOrNull ?? const []),
          ),
      ],
      body: AsyncValueView<List<AppNotification>>(
        value: notifications,
        onRetry: () => ref.invalidate(notificationsProvider),
        isEmpty: (list) => list.isEmpty,
        empty: const AppEmptyState(
          icon: Icons.notifications_none,
          title: Step5Strings.caughtUpTitle,
          message: Step5Strings.caughtUpMessage,
        ),
        data: (list) => ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    if (i > 0) const Divider(),
                    _NotificationTile(notification: list[i]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

AppAccent _accentFor(NotificationType type) => switch (type) {
      NotificationType.budgetOver => AppAccents.coral,
      NotificationType.budgetWarning => AppAccents.amber,
      NotificationType.savingsMilestone => AppAccents.green,
      NotificationType.learning => AppAccents.purple,
    };

IconData _iconFor(NotificationType type) => switch (type) {
      NotificationType.budgetOver => Icons.error_outline,
      NotificationType.budgetWarning => Icons.warning_amber_outlined,
      NotificationType.savingsMilestone => Icons.emoji_events_outlined,
      NotificationType.learning => Icons.menu_book_outlined,
    };

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  void _open(BuildContext context, WidgetRef ref) {
    if (!notification.read) {
      ref.read(notificationRepositoryProvider).markRead(notification.id);
    }
    switch (notification.type) {
      case NotificationType.budgetOver:
      case NotificationType.budgetWarning:
        context.go(AppRoutes.budget);
      case NotificationType.savingsMilestone:
        context.go(AppRoutes.savings);
      case NotificationType.learning:
        context.push(AppRoutes.learning);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final t = context.text;
    final n = notification;
    return Semantics(
      button: true,
      label: '${n.read ? '' : 'Unread. '}${n.title}. ${n.message}. '
          '${Formatters.relativeTime(n.createdAt)}',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _open(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccentIconBox(icon: _iconFor(n.type), accent: _accentFor(n.type)),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: t.titleMedium?.copyWith(
                        fontWeight: n.read ? FontWeight.w600 : FontWeight.w800,
                      ),
                    ),
                    AppSpacing.vXs,
                    Text(n.message, style: t.bodyMedium),
                    AppSpacing.vXs,
                    Text(Formatters.relativeTime(n.createdAt),
                        style: t.bodySmall),
                  ],
                ),
              ),
              if (!n.read)
                Container(
                  width: AppDimensions.badge,
                  height: AppDimensions.badge,
                  margin: const EdgeInsets.only(top: AppSpacing.xs),
                  decoration:
                      BoxDecoration(color: c.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
