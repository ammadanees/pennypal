enum UserRole {
  student,
  admin;

  static UserRole parse(Object? value) =>
      value == 'admin' ? UserRole.admin : UserRole.student;
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.role,
    this.studentId,
    this.photoUrl,
    this.isEmailVerified = true,
    this.studentStatus = 'Full-time',
    this.notificationsEnabled = true,
  });

  final String uid;
  final String fullName;
  final String email;
  final String mobile;
  final UserRole role;
  final String? studentId;
  final String? photoUrl;
  final bool isEmailVerified;
  final String studentStatus;
  final bool notificationsEnabled;

  bool get isAdmin => role == UserRole.admin;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.first.isEmpty ? 'there' : parts.first;
  }

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  AppUser copyWith({
    String? fullName,
    String? mobile,
    String? studentId,
    String? photoUrl,
    bool? isEmailVerified,
    String? studentStatus,
    bool? notificationsEnabled,
  }) =>
      AppUser(
        uid: uid,
        fullName: fullName ?? this.fullName,
        email: email,
        mobile: mobile ?? this.mobile,
        studentId: studentId ?? this.studentId,
        role: role,
        photoUrl: photoUrl ?? this.photoUrl,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        studentStatus: studentStatus ?? this.studentStatus,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );
}
