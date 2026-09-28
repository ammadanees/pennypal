/// All user-facing copy lives here so wording stays consistent.
abstract final class AppStrings {
  static const String appName = 'PennyPal';
  static const String tagline = 'Make Every Penny Count';
  static const String splashFootnote = 'Personal finance for students';
  static const String defaultCurrency = 'Rs.';

  // Actions
  static const String tryAgain = 'Try again';
  static const String addExpense = 'Add expense';
  static const String createBudget = 'Create budget';
  static const String createGoal = 'Create goal';
  static const String next = 'Next';
  static const String skip = 'Skip';
  static const String cancel = 'Cancel';
  static const String save = 'Save changes';
  static const String back = 'Back';

  // Welcome (first launch only)
  static const String welcomeCreateAccount = 'Create account';
  static const String welcomeHaveAccount = 'I already have an account';
  static const List<String> welcomeTitles = [
    'Know where your money goes',
    'Budgets that keep you on track',
    'Save for what matters',
    'Learn money habits as you go',
  ];
  static const List<String> welcomeBodies = [
    'Log expenses and income in seconds, even without a connection. '
        'PennyPal syncs when you are back online.',
    'Set a monthly budget and limits for each category, and get a nudge '
        'before you overspend.',
    'A new laptop, a trip, an emergency fund. Set a goal and watch your '
        'progress grow.',
    'Short lessons and an assistant for budgeting questions. Guidance '
        'here is educational, not financial advice.',
  ];

  // Auth
  static const String loginTitle = 'Welcome back';
  static const String loginSubtitle = 'Sign in to pick up where you left off.';
  static const String registerTitle = 'Create your account';
  static const String registerSubtitle =
      'It takes a minute. No bank details needed.';
  static const String forgotTitle = 'Reset your password';
  static const String forgotSubtitle =
      'Enter your email and we will send you a link to reset it.';
  static const String labelFullName = 'Full name';
  static const String labelStudentId = 'Student ID / Enrollment';
  static const String labelEmail = 'Email';
  static const String labelMobile = 'Mobile number';
  static const String labelPassword = 'Password';
  static const String labelConfirmPassword = 'Confirm password';
  static const String hintEmail = 'you@gmail.com';
  static const String hintMobile = '+92 300 1234567';
  static const String hintStudentId = 'e.g. Student1501103';
  static const String passwordRules =
      'At least 8 characters with upper and lower case letters and a number.';
  static const String signIn = 'Sign in';
  static const String signOut = 'Sign out';
  static const String createAccount = 'Create account';
  static const String forgotPassword = 'Forgot password?';
  static const String sendResetLink = 'Send reset link';
  static const String backToSignIn = 'Back to sign in';
  static const String newHere = 'New to PennyPal?';
  static const String haveAccount = 'Already have an account?';
  static const String resetLinkSent =
      'If an account exists for that email, a reset link is on its way. '
      'Check your inbox and spam folder.';
  static const String authPanelBody =
      'Track spending, plan budgets and reach savings goals, all in one '
      'place built for students.';
  static const List<String> authPanelPoints = [
    'Log expenses in seconds',
    'Stay on budget with gentle alerts',
    'Learn money habits that stick',
  ];

  // Auth errors (never show raw exceptions)
  static const String authInvalidCredentials =
      'Email or password is incorrect.';
  static const String authEmailInUse =
      'An account with this email already exists. Try signing in instead.';
  static const String authWeakPassword =
      'Choose a stronger password with at least 8 characters.';
  static const String authInvalidEmail = 'That email address doesn\'t look right.';
  static const String authUserDisabled =
      'This account has been disabled. Contact support for help.';
  static const String authTooManyRequests =
      'Too many attempts. Wait a few minutes and try again.';
  static const String authNetwork =
      'No connection. Check your internet and try again.';
  static const String authNoSession = 'Please sign in again to continue.';

  // Profile
  static const String profileTitle = 'Profile';
  static const String editProfile = 'Edit profile';
  static const String appearance = 'Appearance';
  static const String account = 'Account';
  static const String signOutConfirmTitle = 'Sign out of PennyPal?';
  static const String signOutConfirmMessage =
      'Your data stays saved. Sign back in any time.';
  static const String profileSaved = 'Profile updated.';

  // About
  static const String aboutTitle = 'About PennyPal';
  static const String aboutPurpose =
      'PennyPal helps students record spending, plan monthly budgets, '
      'build savings goals and learn simple money habits.';
  static const String notABank =
      'PennyPal is a personal finance learning and expense tracking app. '
      'It is not a bank, wallet, payment service, investment platform or '
      'financial advisor, and it never moves real money.';
  static const String comingSoon = 'Coming soon';
  static const String comingSoonMessage =
      'This part of PennyPal is being built and will appear in an update.';

  // Empty states
  static const String emptyTransactionsTitle = 'Your money story starts here.';
  static const String emptyTransactionsMessage =
      'Add your first expense or income and it will show up here.';
  static const String emptyBudgetTitle = 'Create your first monthly budget.';
  static const String emptyBudgetMessage =
      'A budget shows how much is left to spend this month.';
  static const String emptyGoalsTitle = 'Give your next goal a name.';
  static const String emptyGoalsMessage =
      'Saving for a laptop or a trip? Track it here.';

  // Errors
  static const String errorGenericTitle = 'Something went wrong';
  static const String errorGenericMessage =
      'We could not load this right now. Check your connection and try again.';

  // Budget status
  static const String budgetOnTrack = 'On track';
  static const String budgetNearing = 'Nearing your limit';
  static const String budgetOver = 'Over budget';
}
