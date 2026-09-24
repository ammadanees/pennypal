/// A failure whose message is safe to show to students.
class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
