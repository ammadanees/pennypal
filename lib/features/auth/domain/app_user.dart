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
  });

  final String uid;
  final String fullName;
  final String email;
  final String mobile;
  final UserRole role;

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

  AppUser copyWith({String? fullName, String? mobile}) => AppUser(
        uid: uid,
        fullName: fullName ?? this.fullName,
        email: email,
        mobile: mobile ?? this.mobile,
        role: role,
      );
}
