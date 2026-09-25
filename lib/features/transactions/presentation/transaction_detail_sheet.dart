import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/constants/finance_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/accent_icon_box.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_inline_message.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/money_display.dart';
import 'receipt_viewer.dart';
import '../data/transaction_repository.dart';
import '../domain/finance_transaction.dart';
import 'transaction_display.dart';

Future<void> showTransactionDetail(
  BuildContext context,
  FinanceTransaction transaction,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => TransactionDetailSheet(transaction: transaction),
  );
}

class TransactionDetailSheet extends ConsumerWidget {
  const TransactionDetailSheet({super.key, required this.transaction});

  final FinanceTransaction transaction;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await confirmAction(
      context,
      title: FinanceStrings.deleteTransactionTitle,
      message: FinanceStrings.deleteMessage,
      confirmLabel: FinanceStrings.delete,
    );
    if (!ok || !context.mounted) return;
    await ref.read(transactionRepositoryProvider).delete(transaction.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(FinanceStrings.transactionDeleted)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final t = context.text;
    final tx = transaction;
    final tint = tx.isIncome ? c.income : c.expense;

    final rows = <(String, String)>[
      (FinanceStrings.labelDate, DateFormat('EEE, d MMM y, h:mm a').format(tx.date)),
      if (tx.isIncome)
        (FinanceStrings.labelSource, tx.source ?? '')
      else ...[
        (FinanceStrings.labelCategory, tx.category?.label ?? ''),
        if (tx.paymentMode != null)
          (FinanceStrings.labelPaidWith, tx.paymentMode!.label),
      ],
      if (tx.description.isNotEmpty && tx.description != tx.title)
        (FinanceStrings.labelNote, tx.description),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AccentIconBox(icon: tx.icon, accent: tx.accent),
              AppSpacing.hMd,
              Expanded(child: Text(tx.title, style: t.titleLarge)),
            ],
          ),
          AppSpacing.vMd,
          MoneyDisplay(amount: tx.amount, size: MoneySize.hero, kind: tx.kind),
          if (tx.receiptImageUrl != null) ...[
            AppSpacing.vMd,
            GestureDetector(
              onTap: () => showReceiptViewer(context, tx.receiptImageUrl!),
              child: ClipRRect(
                borderRadius: AppRadius.mdAll,
                child: Image.network(
                  tx.receiptImageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: c.surfaceElevated,
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image_outlined, color: c.textMuted),
                  ),
                ),
              ),
            ),
          ],
          AppSpacing.vMd,
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(label, style: t.bodySmall),
                  ),
                  Expanded(child: Text(value, style: t.bodyMedium)),
                ],
              ),
            ),
          if (tx.pending) ...[
            AppSpacing.vSm,
            const AppInlineMessage(
              message: FinanceStrings.waitingToSync,
              kind: InlineMessageKind.info,
            ),
          ],
          AppSpacing.vLg,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: FinanceStrings.edit,
                  icon: Icons.edit_outlined,
                  variant: AppButtonVariant.outlined,
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push(AppRoutes.transactionEdit, extra: tx);
                  },
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: AppButton(
                  label: FinanceStrings.delete,
                  icon: Icons.delete_outline,
                  variant: AppButtonVariant.tonal,
                  onPressed: () => _delete(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
