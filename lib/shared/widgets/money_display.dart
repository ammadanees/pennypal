import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/currency_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';

enum MoneySize { hero, title, body }

enum MoneyKind { neutral, income, expense }

class MoneyDisplay extends ConsumerWidget {
  const MoneyDisplay({
    super.key,
    required this.amount,
    this.size = MoneySize.title,
    this.kind = MoneyKind.neutral,
    this.currency,
    this.color,
  });

  final double amount;
  final MoneySize size;
  final MoneyKind kind;
  final String? currency;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCurrency = currency ?? ref.watch(currencyProvider);
    final c = context.colors;
    final resolved = color ??
        switch (kind) {
          MoneyKind.income => c.income,
          MoneyKind.expense => c.expense,
          MoneyKind.neutral => c.textPrimary,
        };

    final base = switch (size) {
      MoneySize.hero => AppTextStyles.moneyHero(resolved),
      MoneySize.title => AppTextStyles.moneyTitle(resolved),
      MoneySize.body => AppTextStyles.moneyBody(resolved),
    };
    final prefix = base.copyWith(
      fontSize: (base.fontSize ?? 15) * 0.55,
      fontWeight: FontWeight.w600,
    );

    final sign = switch (kind) {
      MoneyKind.income => '+',
      MoneyKind.expense => '\u2212',
      MoneyKind.neutral => amount < 0 ? '\u2212' : '',
    };
    final kindWord = switch (kind) {
      MoneyKind.income => 'Income ',
      MoneyKind.expense => 'Expense ',
      MoneyKind.neutral => '',
    };
    final formatted = Formatters.number(amount.abs());

    return Semantics(
      label: '$kindWord$activeCurrency $formatted',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            TextSpan(text: sign),
            TextSpan(text: '$activeCurrency ', style: prefix),
            TextSpan(text: formatted),
          ],
        ),
      ),
    );
  }
}
