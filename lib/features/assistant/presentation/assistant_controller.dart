import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/step5_strings.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/id_generator.dart';
import '../../budgets/data/budget_repository.dart';
import '../../dashboard/domain/finance_calculator.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../reports/domain/report_calculator.dart';
import '../../savings/data/savings_repository.dart';
import '../../savings/domain/savings_calculator.dart';
import '../../transactions/data/transaction_repository.dart';
import '../domain/assistant_engine.dart';

final assistantServiceProvider =
    Provider<AssistantService>((ref) => const RuleBasedAssistant());

/// The numbers the assistant can refer to, taken from the student's data.
final assistantContextProvider = Provider<AssistantContext>((ref) {
  final now = DateTime.now();
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? const [];
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? const [];
  final goals = ref.watch(savingsGoalsProvider).valueOrNull ?? const [];

  final summary = FinanceCalculator.monthSummary(transactions, now);
  final budget = budgets.forMonth(AppDates.startOfMonth(now));

  String? topLabel;
  double? topShare;
  if (summary.byCategory.isNotEmpty && summary.expense > 0) {
    final top = summary.byCategory.entries.reduce((a, b) => a.value >= b.value ? a : b);
    topLabel = top.key.label;
    topShare = top.value / summary.expense;
  }

  final spentMonths = ReportCalculator.monthlyTotals(transactions, now, months: 3)
      .where((m) => m.expense > 0)
      .toList();
  final avg = spentMonths.isEmpty
      ? null
      : spentMonths.fold<double>(0, (s, m) => s + m.expense) / spentMonths.length;

  final active = goals.where((g) => !g.isCompleted).toList()
    ..sort((a, b) => b.currentAmount.compareTo(a.currentAmount));
  final goal = active.firstOrNull;
  final progress = goal == null ? null : SavingsCalculator.progress(goal);

  return AssistantContext(
    monthIncome: summary.income,
    monthExpense: summary.expense,
    budgetTotal: budget?.totalAmount,
    budgetSpent: budget == null
        ? null
        : BudgetCalculator.status(budget, summary).spent,
    topCategoryLabel: topLabel,
    topCategoryShare: topShare,
    avgMonthlyExpense: avg,
    goalName: goal?.name,
    goalRemaining: progress?.remaining,
    goalMonthly: goal?.monthlyContribution,
    goalMonthsToGo: progress?.monthsToGo,
  );
});

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.fromUser,
    this.isError = false,
    this.retryQuestion,
  });

  final String id;
  final String text;
  final bool fromUser;
  final bool isError;
  final String? retryQuestion;
}

class AssistantState {
  const AssistantState({
    this.messages = const [],
    this.isTyping = false,
    this.suggestions = starterQuestions,
  });

  final List<ChatMessage> messages;
  final bool isTyping;
  final List<String> suggestions;

  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    List<String>? suggestions,
  }) =>
      AssistantState(
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
        suggestions: suggestions ?? this.suggestions,
      );
}

class AssistantController extends Notifier<AssistantState> {
  @override
  AssistantState build() => const AssistantState();

  Future<void> send(String text) async {
    final question = text.trim();
    if (question.isEmpty || state.isTyping) return;
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(id: IdGenerator.next(), text: question, fromUser: true),
      ],
    );
    await _ask(question);
  }

  Future<void> retry(ChatMessage failed) async {
    final question = failed.retryQuestion;
    if (question == null || state.isTyping) return;
    state = state.copyWith(
      messages: [for (final m in state.messages) if (m.id != failed.id) m],
    );
    await _ask(question);
  }

  Future<void> _ask(String question) async {
    state = state.copyWith(isTyping: true, suggestions: const []);
    try {
      final reply = await ref
          .read(assistantServiceProvider)
          .ask(question, ref.read(assistantContextProvider));
      state = state.copyWith(
        isTyping: false,
        messages: [
          ...state.messages,
          ChatMessage(id: IdGenerator.next(), text: reply.text, fromUser: false),
        ],
        suggestions: reply.suggestions,
      );
    } catch (_) {
      state = state.copyWith(
        isTyping: false,
        messages: [
          ...state.messages,
          ChatMessage(
            id: IdGenerator.next(),
            text: Step5Strings.assistantError,
            fromUser: false,
            isError: true,
            retryQuestion: question,
          ),
        ],
        suggestions: starterQuestions,
      );
    }
  }

  void clear() => state = const AssistantState();
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(AssistantController.new);
