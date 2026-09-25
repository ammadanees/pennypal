import '../../../data/record_store.dart';

enum SupportStatus { open, answered, closed }

class SupportQuery {
  const SupportQuery({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.submittedOn,
    this.adminResponse,
    this.pending = false,
  });

  final String id;
  final String subject;
  final String message;
  final SupportStatus status;
  final DateTime submittedOn;
  final String? adminResponse;
  final bool pending;

  factory SupportQuery.fromRecord(StoredRecord record) {
    final d = record.data;
    return SupportQuery(
      id: record.id,
      subject: (d['subject'] as String?) ?? '',
      message: (d['message'] as String?) ?? '',
      status: SupportStatus.values.where((s) => s.name == d['status']).firstOrNull ??
          SupportStatus.open,
      submittedOn: (d['submittedOn'] as DateTime?) ?? DateTime.now(),
      adminResponse: d['adminResponse'] as String?,
      pending: record.hasPendingWrites,
    );
  }
}
