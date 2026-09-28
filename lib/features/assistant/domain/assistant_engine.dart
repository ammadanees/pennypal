import '../../../core/utils/formatters.dart';

class AssistantContext {
  const AssistantContext({
    this.monthIncome = 0,
    this.monthExpense = 0,
    this.budgetTotal,
    this.budgetSpent,
    this.topCategoryLabel,
    this.topCategoryShare,
    this.avgMonthlyExpense,
    this.goalName,
    this.goalRemaining,
    this.goalMonthly,
    this.goalMonthsToGo,
  });

  final double monthIncome;
  final double monthExpense;
  final double? budgetTotal;
  final double? budgetSpent;
  final String? topCategoryLabel;
  final double? topCategoryShare;
  final double? avgMonthlyExpense;
  final String? goalName;
  final double? goalRemaining;
  final double? goalMonthly;
  final int? goalMonthsToGo;

  bool get hasBudget => budgetTotal != null && budgetTotal! > 0;
}

class AssistantReply {
  const AssistantReply(this.text, {this.suggestions = const []});

  final String text;
  final List<String> suggestions;
}

abstract class AssistantService {
  Future<AssistantReply> ask(String question, AssistantContext context);
}

const List<String> starterQuestions = [
  'How much should I save each month?',
  'Where did my money go this month?',
  'Am I overspending?',
  'How do I build an emergency fund?',
];

class RuleBasedAssistant implements AssistantService {
  const RuleBasedAssistant({this.delay = const Duration(milliseconds: 600)});

  final Duration delay;

  @override
  Future<AssistantReply> ask(String question, AssistantContext ctx) async {
    await Future<void>.delayed(delay);
    return answer(question, ctx);
  }

  static const _footnote = 'General education, not financial advice.';

  static bool _has(String q, List<String> words) => words.any(q.contains);

  static AssistantReply answer(String question, AssistantContext ctx) {
    final q = question.toLowerCase().trim();
    final m = Formatters.money;

    if (q.isEmpty) return _fallback();

    if (_has(q, [
      'invest',
      'stock',
      'crypto',
      'bitcoin',
      'forex',
      'mutual fund',
      'insurance',
      'tax',
      'loan',
      'interest rate'
    ])) {
      return const AssistantReply(
        'I can\'t recommend investments, loans or tax choices, and I can\'t tell what is right for your situation. '
        'For those, a qualified professional is the right person to ask. '
        'What I can help with is budgeting, saving habits and understanding your spending. $_footnote',
        suggestions: [
          'How much should I save each month?',
          'What is a budget?'
        ],
      );
    }

    if (_has(q, [
      'send money',
      'transfer',
      'pay my',
      'bank account',
      'top up',
      'withdraw'
    ])) {
      return const AssistantReply(
        'PennyPal never moves real money. It is a place to record and understand your spending. '
        'Payments and transfers happen in your bank or wallet app, and you can log them here afterwards.',
        suggestions: ['Where did my money go this month?'],
      );
    }

    if (RegExp(
            r'^(hi|hello|hey|salam|assalam|good (morning|afternoon|evening))\b')
        .hasMatch(q)) {
      return const AssistantReply(
        'Hi! I\'m your PennyPal helper. Ask me about budgeting, saving or your spending and I\'ll explain in plain words.',
        suggestions: starterQuestions,
      );
    }

    if (_has(q, [
      'overspend',
      'over budget',
      'too much',
      'spending too',
      'spent too',
      'overspending'
    ])) {
      if (ctx.hasBudget) {
        final total = ctx.budgetTotal!;
        final spent = ctx.budgetSpent ?? ctx.monthExpense;
        final ratio = spent / total;
        final top = ctx.topCategoryLabel == null
            ? ''
            : ' ${ctx.topCategoryLabel} is your biggest category'
                '${ctx.topCategoryShare == null ? '' : ' at ${Formatters.percent(ctx.topCategoryShare!)} of spending'}.';
        if (ratio >= 1) {
          return AssistantReply(
            'You have spent ${m(spent)} against a budget of ${m(total)}, which is ${m(spent - total)} over.$top '
            'A useful next step is to pause optional spending for the rest of the month and look at the category that grew most.',
            suggestions: [
              'What is the difference between needs and wants?',
              'How do I cut small expenses?'
            ],
          );
        }
        return AssistantReply(
          'You have used ${Formatters.percent(ratio)} of your ${m(total)} budget, with ${m(total - spent)} left.$top '
          '${ratio >= 0.8 ? 'That is close to the limit, so it may be worth slowing down on optional spending. ' : 'You are within your plan so far. '}$_footnote',
          suggestions: ['Where did my money go this month?'],
        );
      }
      return const AssistantReply(
        'I can\'t tell yet because there is no budget for this month. Create one in the Budget tab and I\'ll compare your spending with it. '
        'As a first check: if you spend more than you earn in a month, that is overspending.',
        suggestions: ['What is a budget?', 'What is the 50/30/20 rule?'],
      );
    }

    if (_has(q,
        ['where', 'went', 'biggest', 'top spend', 'spending on', 'spent on'])) {
      if (ctx.monthExpense <= 0) {
        return const AssistantReply(
          'There is no spending recorded this month yet. Add an expense and I\'ll show you where your money is going.',
          suggestions: ['What is a budget?'],
        );
      }
      final top = ctx.topCategoryLabel == null
          ? ''
          : ' Your biggest category is ${ctx.topCategoryLabel}'
              '${ctx.topCategoryShare == null ? '' : ' at ${Formatters.percent(ctx.topCategoryShare!)}'}.';
      return AssistantReply(
        'This month you have spent ${m(ctx.monthExpense)}.$top The Reports tab shows every category with amounts and percentages.',
        suggestions: [
          'Am I overspending?',
          'How much should I save each month?'
        ],
      );
    }

    if (_has(q, ['emergency'])) {
      final base = ctx.avgMonthlyExpense;
      final number = (base != null && base > 0)
          ? ' Your spending has averaged about ${m(base)} a month, so a first target could be around ${m(base)}.'
          : ' A common first target is one month of basic expenses.';
      return AssistantReply(
        'An emergency fund is money kept for unexpected but necessary costs, like a repair or a medical visit.$number '
        'Keep it separate from everyday money and build it in small steps. $_footnote',
        suggestions: [
          'How much should I save each month?',
          'Tell me about my savings goal'
        ],
      );
    }

    if (_has(
        q, ['goal', 'laptop', 'target', 'when will i reach', 'how long'])) {
      if (ctx.goalName != null && ctx.goalRemaining != null) {
        final months = ctx.goalMonthsToGo;
        final monthly = ctx.goalMonthly ?? 0;
        return AssistantReply(
          'For "${ctx.goalName}" you still need ${m(ctx.goalRemaining!)}.'
          '${months != null && monthly > 0 ? ' At ${m(monthly)} a month that is about $months more months.' : ' Set a monthly amount on the goal and I can estimate the time.'}',
          suggestions: [
            'How much should I save each month?',
            'Small habits that grow savings'
          ],
        );
      }
      return const AssistantReply(
        'You have no active savings goal yet. Create one in the Savings tab with a target and date, and I can help you work out a monthly amount.',
        suggestions: ['How much should I save each month?'],
      );
    }

    if (_has(q, ['save', 'saving', 'savings'])) {
      final income = ctx.monthIncome;
      final twenty = income > 0
          ? ' For your income of ${m(income)} that would be about ${m(income * 0.2)} a month.'
          : '';
      return AssistantReply(
        'A common starting point is to save around 20% of what you earn, but the right amount depends on your costs. '
        'Even a smaller amount is fine if you do it every month.$twenty '
        'Try paying yourself first: set the amount aside as soon as money arrives. $_footnote',
        suggestions: [
          'How do I build an emergency fund?',
          'Tell me about my savings goal'
        ],
      );
    }

    if (_has(q, ['50/30/20', '50 30 20', 'rule'])) {
      final income = ctx.monthIncome;
      final split = income > 0
          ? ' With ${m(income)}, that is ${m(income * 0.5)} for needs, ${m(income * 0.3)} for wants and ${m(income * 0.2)} for savings.'
          : '';
      return AssistantReply(
        'The 50/30/20 guide splits money into 50% needs, 30% wants and 20% savings.$split '
        'It is only a starting point. If your needs take more, adjust it to fit. $_footnote',
        suggestions: [
          'What is a budget?',
          'What is the difference between needs and wants?'
        ],
      );
    }

    if (_has(q, ['budget'])) {
      final status = ctx.hasBudget
          ? ' Your budget this month is ${m(ctx.budgetTotal!)}.'
          : ' You can create one in the Budget tab.';
      return AssistantReply(
        'A budget is a plan for your money: what comes in, what goes out and what is left.$status '
        'List your income, cover needs first, then decide how much goes to wants and savings.',
        suggestions: ['What is the 50/30/20 rule?', 'Am I overspending?'],
      );
    }

    if (_has(q, ['need', 'want'])) {
      return const AssistantReply(
        'Needs are things you must pay for, like basic food, transport to class, books, rent and bills. Wants are extras that make life nicer. '
        'A quick test: what happens if I go without this for a month? Many things are part need, part want, like a phone plan. The basic plan is the need and the upgrade is the want.',
        suggestions: ['How do I cut small expenses?', 'What is a budget?'],
      );
    }

    if (_has(
        q, ['cut', 'reduce', 'subscription', 'small expense', 'cheaper'])) {
      final top = ctx.topCategoryLabel == null
          ? ''
          : ' Your biggest category this month is ${ctx.topCategoryLabel}, so that is a good place to look first.';
      return AssistantReply(
        'Three easy ways to trim spending: track small purchases for a month, wait 24 hours before non-essential buys, and review subscriptions you have not used lately.$top $_footnote',
        suggestions: ['Where did my money go this month?'],
      );
    }

    if (_has(q, ['income', 'earn', 'allowance', 'salary', 'freelance'])) {
      return const AssistantReply(
        'Knowing your income is the base of any budget. If it changes from month to month, plan around the lower, more certain amount and treat extra as a bonus for savings. '
        'You can record each source when you add income.',
        suggestions: [
          'What is a budget?',
          'How much should I save each month?'
        ],
      );
    }

    return _fallback();
  }

  static AssistantReply _fallback() => const AssistantReply(
        'I\'m not sure about that one. I can help with budgeting, saving and understanding your spending. Try one of these:',
        suggestions: starterQuestions,
      );
}
