import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/finance_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../data/card_repository.dart';
import '../domain/payment_card.dart';
import 'add_card_sheet.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  Future<void> _deleteCard(
    BuildContext context,
    WidgetRef ref,
    PaymentCard card,
  ) async {
    final confirmed = await confirmAction(
      context,
      title: 'Remove Card',
      message: 'Are you sure you want to remove "${card.name}"?',
      confirmLabel: FinanceStrings.delete,
    );
    if (!confirmed || !context.mounted) return;

    await ref.read(cardRepositoryProvider).delete(card.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Card "${card.name}" removed.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final t = context.text;
    final cardsAsync = ref.watch(cardsProvider);

    return AppScaffold(
      title: 'Payment Cards',
      floatingActionButton: cardsAsync.maybeWhen(
        data: (cards) => cards.length < CardRepository.maxCardsPerUser
            ? FloatingActionButton.extended(
                heroTag: null,
                onPressed: () => showAddCardSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Card'),
              )
            : null,
        orElse: () => null,
      ),
      body: AsyncValueView<List<PaymentCard>>(
        value: cardsAsync,
        onRetry: () => ref.invalidate(cardsProvider),
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppEmptyState(
                  icon: Icons.credit_card_outlined,
                  title: 'No Cards Added',
                  message:
                      'Attach up to 2 debit, credit, or student cards to easily track and filter spending by card.',
                  actionLabel: 'Add Your First Card',
                  onAction: () => showAddCardSheet(context),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppDimensions.fabClearance + 24,
            ),
            children: [
              // Capacity & Info Banner
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: c.primarySoft,
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Icon(Icons.wallet_rounded,
                          color: c.primary, size: 22),
                    ),
                    AppSpacing.hMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Cards: ${cards.length} of ${CardRepository.maxCardsPerUser}',
                            style: t.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cards.length >= CardRepository.maxCardsPerUser
                                ? 'Card limit reached. Tap "Edit" to customize palettes or remove one.'
                                : 'Tap "Edit" on any card to change its gradient theme and info.',
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.vMd,

              // List of 3D Cards
              for (final card in cards) ...[
                _FullCardView(
                  card: card,
                  onEdit: () => showAddCardSheet(context, existingCard: card),
                  onDelete: () => _deleteCard(context, ref, card),
                ),
                AppSpacing.vLg,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FullCardView extends StatelessWidget {
  const _FullCardView({
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  final PaymentCard card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: c.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 3D Glassmorphic Card Graphic
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 196,
              decoration: BoxDecoration(
                gradient: card.gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: card.gradient.colors.first.withOpacity(0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bank & Contactless Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (card.bank != null && card.bank!.isNotEmpty)
                            ? card.bank!.toUpperCase()
                            : 'PENNYPAL WALLET',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              card.cardType.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.contactless_rounded,
                              color: Colors.white70, size: 20),
                        ],
                      ),
                    ],
                  ),

                  // Chip & Last 4
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '••••  ••••  ••••  ${card.last4?.isNotEmpty == true ? card.last4 : '••••'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ],
                  ),

                  // Cardholder & Expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CARD NICKNAME',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              card.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EXPIRES',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            '12/28',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action Toolbar
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onEdit();
                  },
                  icon: const Icon(Icons.palette_outlined, size: 18),
                  label: const Text('Edit & Change Color'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: c.expense,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onDelete();
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Remove'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
