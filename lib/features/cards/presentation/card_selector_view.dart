import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../data/card_repository.dart';
import '../domain/payment_card.dart';
import 'add_card_sheet.dart';

class CardSelectorView extends ConsumerWidget {
  const CardSelectorView({
    super.key,
    required this.selectedCardId,
    required this.onCardSelected,
  });

  final String? selectedCardId;
  final ValueChanged<PaymentCard?> onCardSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final t = context.text;
    final cardsAsync = ref.watch(cardsProvider);

    return cardsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (cards) {
        final canAddMore = cards.length < CardRepository.maxCardsPerUser;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Select Card', style: t.labelLarge),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: cards.length >= CardRepository.maxCardsPerUser
                            ? c.surfaceElevated
                            : c.primary.withOpacity(0.1),
                        borderRadius: AppRadius.pillAll,
                        border: Border.all(
                          color: cards.length >= CardRepository.maxCardsPerUser
                              ? c.border
                              : c.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${cards.length}/${CardRepository.maxCardsPerUser}',
                        style: t.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cards.length >= CardRepository.maxCardsPerUser
                              ? c.textMuted
                              : c.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (canAddMore)
                  TextButton.icon(
                    onPressed: () async {
                      final created = await showAddCardSheet(context);
                      if (created != null) {
                        onCardSelected(created);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Card'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                else
                  Text(
                    'Limit reached (2 max)',
                    style: t.bodySmall?.copyWith(
                      color: c.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            AppSpacing.vXs,
            if (cards.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: c.surfaceElevated,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.credit_card_off_outlined, color: c.textMuted),
                    AppSpacing.hMd,
                    Expanded(
                      child: Text(
                        'No cards added yet. You can attach up to 2 cards to track card payments.',
                        style: t.bodySmall,
                      ),
                    ),
                    AppSpacing.hSm,
                    FilledButton.tonal(
                      onPressed: () async {
                        final created = await showAddCardSheet(context);
                        if (created != null) {
                          onCardSelected(created);
                        }
                      },
                      child: const Text('Add Card'),
                    ),
                  ],
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final card in cards) ...[
                      _CardChip(
                        card: card,
                        isSelected: card.id == selectedCardId,
                        onTap: () {
                          if (card.id == selectedCardId) {
                            onCardSelected(null);
                          } else {
                            onCardSelected(card);
                          }
                        },
                        onDelete: () async {
                          final ok = await confirmAction(
                            context,
                            title: 'Remove card?',
                            message:
                                'Are you sure you want to remove "${card.name}"?',
                            confirmLabel: 'Remove',
                          );
                          if (!ok) return;
                          if (card.id == selectedCardId) {
                            onCardSelected(null);
                          }
                          await ref
                              .read(cardRepositoryProvider)
                              .delete(card.id);
                        },
                      ),
                      AppSpacing.hSm,
                    ],
                    if (canAddMore)
                      OutlinedButton.icon(
                        onPressed: () async {
                          final created = await showAddCardSheet(context);
                          if (created != null) {
                            onCardSelected(created);
                          }
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New Card'),
                        style: OutlinedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.pillAll,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip({
    required this.card,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final PaymentCard card;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    final background = isSelected ? c.primary : c.surfaceElevated;
    final foreground = isSelected ? c.onPrimary : c.textPrimary;
    final border = isSelected ? c.primary : c.border;

    return Material(
      color: background,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.credit_card,
                size: 18,
                color: foreground,
              ),
              AppSpacing.hSm,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.name,
                    style: t.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (card.last4 != null && card.last4!.isNotEmpty)
                    Text(
                      '•••• ${card.last4} (${card.cardType})',
                      style: t.bodySmall?.copyWith(
                        color: foreground.withAlpha(200),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              AppSpacing.hSm,
              InkWell(
                onTap: onDelete,
                borderRadius: AppRadius.pillAll,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: foreground.withAlpha(180),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
