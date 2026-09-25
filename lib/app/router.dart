import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_durations.dart';
import '../features/about/presentation/about_screen.dart';
import '../features/learning/presentation/learning_screen.dart';
import '../features/learning/presentation/lesson_screen.dart';
import '../features/assistant/presentation/assistant_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/support/presentation/feedback_screen.dart';
import '../features/support/presentation/support_screen.dart';
import '../features/budgets/domain/budget.dart';
import '../features/budgets/presentation/budget_form_screen.dart';
import '../features/budgets/presentation/budget_screen.dart';
import '../features/dashboard/presentation/home_screen.dart';
import '../features/savings/domain/savings_goal.dart';
import '../features/savings/presentation/goal_form_screen.dart';
import '../features/savings/presentation/savings_screen.dart';
import '../features/transactions/domain/finance_transaction.dart';
import '../features/transactions/presentation/activity_screen.dart';
import '../features/transactions/presentation/transaction_form_screen.dart';
import '../core/utils/app_dates.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/admin_feedback_screen.dart';
import '../features/admin/presentation/admin_shell.dart';
import '../features/admin/presentation/admin_support_screen.dart';
import '../features/admin/presentation/admin_users_screen.dart';
import '../features/auth/data/auth_providers.dart';
import '../features/auth/domain/app_user.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/onboarding/presentation/onboarding_controller.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/shell/presentation/more_screen.dart';
import '../features/shell/presentation/student_shell.dart';
import '../features/splash/presentation/splash_screen.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AsyncValue<AppUser?>>(authStateProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (_, state) => _fade(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, state) => _fade(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => StudentShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.activity,
              builder: (_, __) => const ActivityScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.budget,
              builder: (_, __) => const BudgetScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.savings,
              builder: (_, __) => const SavingsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.more, builder: (_, __) => const MoreScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.transactionNew,
        builder: (_, state) => TransactionFormScreen(
          initialType: state.extra is TransactionType
              ? state.extra! as TransactionType
              : TransactionType.expense,
        ),
      ),
      GoRoute(
        path: AppRoutes.transactionEdit,
        builder: (_, state) => TransactionFormScreen(
          existing: state.extra is FinanceTransaction
              ? state.extra! as FinanceTransaction
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.budgetEdit,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is Budget) {
            return BudgetFormScreen(month: extra.month, existing: extra);
          }
          return BudgetFormScreen(
            month: extra is DateTime
                ? extra
                : AppDates.startOfMonth(DateTime.now()),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.goalEdit,
        builder: (_, state) => GoalFormScreen(
          existing: state.extra is SavingsGoal ? state.extra! as SavingsGoal : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (_, __) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.assistant,
        builder: (_, __) => const AssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.feedback,
        builder: (_, __) => const FeedbackScreen(),
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (_, __) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.learning,
        builder: (_, __) => const LearningScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.lessonBase}/:id',
        builder: (_, state) =>
            LessonScreen(lessonId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(path: AppRoutes.about, builder: (_, __) => const AboutScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AdminShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.admin,
              builder: (_, __) => const AdminDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.adminUsers,
              builder: (_, __) => const AdminUsersScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.adminSupport,
              builder: (_, __) => const AdminSupportScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.adminFeedback,
              builder: (_, __) => const AdminFeedbackScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});

/// Central guard. The splash screen always hands off to /welcome and this
/// decides the real destination:
///  - signed out, first launch  -> welcome (shown once)
///  - signed out, seen welcome  -> sign in
///  - signed in                 -> student home or admin portal by role
String? _redirect(Ref ref, String location) {
  if (location == AppRoutes.splash) return null;

  final auth = ref.read(authStateProvider);
  if (auth.isLoading) return AppRoutes.splash;

  final user = auth.valueOrNull;
  final seenWelcome = ref.read(onboardingSeenProvider);
  final onAuthRoute = AppRoutes.authRoutes.contains(location);

  if (user == null) {
    if (location == AppRoutes.welcome) {
      return seenWelcome ? AppRoutes.login : null;
    }
    if (onAuthRoute) return null;
    return seenWelcome ? AppRoutes.login : AppRoutes.welcome;
  }

  final landing = user.isAdmin ? AppRoutes.admin : AppRoutes.home;
  if (onAuthRoute) return landing;

  if (user.isAdmin) {
    const adminAllowed = {
      AppRoutes.admin,
      AppRoutes.adminUsers,
      AppRoutes.adminSupport,
      AppRoutes.adminFeedback,
      AppRoutes.profile,
      AppRoutes.about,
    };
    return adminAllowed.contains(location) ? null : AppRoutes.admin;
  }
  if (adminOnlyRoutes.contains(location)) return AppRoutes.home;
  return null;
}

const adminOnlyRoutes = {
  AppRoutes.admin,
  AppRoutes.adminUsers,
  AppRoutes.adminSupport,
  AppRoutes.adminFeedback,
};

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.slow,
    transitionsBuilder: (_, animation, __, page) =>
        FadeTransition(opacity: animation, child: page),
  );
}
