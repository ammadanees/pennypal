abstract final class LearningStrings {
  static const String title = 'Learn';
  static const String allTopics = 'All';
  static const String startNudge =
      'Start learning one small money habit today.';
  static const String startHere = 'Start here';
  static const String progressTitle = 'Your progress';
  static const String markRead = 'Mark as read';
  static const String markedRead = 'Read. Tap to undo';
  static const String nextLesson = 'Next lesson';
  static const String read = 'Read';
  static const String notFoundTitle = 'Lesson not found';
  static const String notFoundMessage = 'This lesson is no longer available.';
  static const String backToLessons = 'Back to lessons';
  static const String noLessonsTitle = 'No lessons here yet';
  static const String noLessonsMessage = 'Try another topic.';
  static const String disclaimer =
      'Lessons are general education, not financial advice. Your situation '
      'may be different.';

  static String readCount(int read, int total) =>
      '$read of $total lessons read';
  static String minutes(int m) => '$m min read';
}
