abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String activity = '/activity';
  static const String budget = '/budget';
  static const String savings = '/savings';
  static const String more = '/more';

  static const String transactionNew = '/transaction/new';
  static const String transactionEdit = '/transaction/edit';
  static const String budgetEdit = '/budget/edit';
  static const String goalEdit = '/savings/edit';

  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String assistant = '/assistant';
  static const String feedback = '/feedback';
  static const String support = '/support';
  static const String learning = '/learning';
  static const String lessonBase = '/learning/lesson';

  static const String profile = '/profile';
  static const String about = '/about';
  static const String admin = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminSupport = '/admin/support';
  static const String adminFeedback = '/admin/feedback';
  static const String adminContent = '/admin/content';

  static const Set<String> authRoutes = {
    welcome,
    login,
    register,
    verifyEmail,
    forgotPassword,
  };
}
