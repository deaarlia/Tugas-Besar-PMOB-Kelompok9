import 'report_reason.dart';
import 'report_target.dart';

/// Status laporan (PRD Flow 5). Laporan baru selalu "Menunggu".
enum ReportStatus {
  menunggu('Menunggu'),
  diproses('Diproses'),
  ditolak('Ditolak');

  const ReportStatus(this.label);

  final String label;

  String get apiValue => name;
}

/// Hasil workflow: laporan yang dikembalikan form ke layar sebelumnya
/// dan ditampilkan di "Laporan Saya".
class Report {
  const Report({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.targetExcerpt,
    required this.targetAuthorName,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.description,
    this.targetCommunityName,
  });

  final String id;
  final String reporterId;
  final ReportTargetType targetType;
  final String targetId;
  final String targetExcerpt;
  final String targetAuthorName;
  final ReportReason reason;
  final String? description;
  final String? targetCommunityName;
  final ReportStatus status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'report_id': id,
        'reporter_id': reporterId,
        'target_type': targetType.apiValue,
        'target_id': targetId,
        'reason': reason.apiValue,
        'description': description,
        'status': status.apiValue,
        'created_at': createdAt.toIso8601String(),
      };
}