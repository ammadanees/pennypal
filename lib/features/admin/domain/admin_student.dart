import '../../../data/record_store.dart';

class AdminStudent {
  const AdminStudent({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.mobile,
    this.createdAt,
    this.lastLogin,
  });

  final String uid;
  final String fullName;
  final String email;
  final String mobile;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  factory AdminStudent.fromRecord(StoredRecord record) {
    final d = record.data;
    return AdminStudent(
      uid: record.id,
      fullName: (d['fullName'] as String?) ?? 'Student',
      email: (d['email'] as String?) ?? '',
      mobile: (d['mobile'] as String?) ?? '',
      createdAt: d['createdAt'] as DateTime?,
      lastLogin: d['lastLogin'] as DateTime?,
    );
  }
}
