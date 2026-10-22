// lib/models/report.dart

/// Model laporan SEMENTARA untuk FR-11. Ganti dengan model laporan FR-04 saat merge.
enum ReportContentType {
  thread('Utas'),
  comment('Komentar');

  const ReportContentType(this.label);
  final String label;
}

enum ReportStatus {
  pending('Menunggu'),
  rejected('Ditolak'),
  deleted('Dihapus');

  const ReportStatus(this.label);
  final String label;
}

enum ReportReason {
  spam(
    'Spam',
    'Spam atau Promosi',
    'Konten berulang, iklan, atau promosi yang tidak relevan dengan komunitas.',
  ),
  hoax(
    'Hoaks',
    'Informasi Palsu / Hoaks Seputar Akademik',
    'Penyebaran informasi keliru terkait pengumuman fakultas atau jadwal perkuliahan.',
  ),
  sara(
    'SARA',
    'Konten SARA',
    'Konten yang menyerang suku, agama, ras, atau antargolongan.',
  ),
  harassment(
    'Pelecehan',
    'Pelecehan atau Perundungan',
    'Konten yang menyerang, merendahkan, atau mengintimidasi individu tertentu.',
  ),
  urgent('Mendesak', 'Mendesak', 'Konten yang memerlukan penanganan segera.'),
  other('Lainnya', 'Alasan Lainnya', 'Alasan di luar kategori yang tersedia.');

  const ReportReason(this.label, this.title, this.detail);
  final String label;
  final String title;
  final String detail;
}

class Report {
  const Report({
    required this.id,
    required this.code,
    required this.contentType,
    required this.contentText,
    required this.contentAuthor,
    required this.contentPostedAt,
    required this.reason,
    required this.reporterNote,
    required this.createdAt,
    this.contentId,
    this.upvotes = 0,
    this.commentCount = 0,
    this.status = ReportStatus.pending,
  });

  final String id;
  final String code; // contoh: #REP-104
  final ReportContentType contentType;
  final String? contentId; // id utas jika contentType == thread
  final String contentText;
  final String contentAuthor;
  final DateTime contentPostedAt;
  final int upvotes;
  final int commentCount;
  final ReportReason reason;
  final String reporterNote;
  final DateTime createdAt;
  final ReportStatus status;

  Report copyWith({ReportStatus? status}) => Report(
    id: id,
    code: code,
    contentType: contentType,
    contentId: contentId,
    contentText: contentText,
    contentAuthor: contentAuthor,
    contentPostedAt: contentPostedAt,
    upvotes: upvotes,
    commentCount: commentCount,
    reason: reason,
    reporterNote: reporterNote,
    createdAt: createdAt,
    status: status ?? this.status,
  );
}
