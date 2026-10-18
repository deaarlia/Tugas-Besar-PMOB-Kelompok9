import 'report_target.dart';

/// Model tampilan utas.
///
/// TODO Modul 3: ganti dengan model utas dari REST API (Post/Thread di PRD 2.5).
class Thread {
  const Thread({
    required this.id,
    required this.authorName,
    required this.authorInfo,
    required this.timeAgo,
    required this.title,
    required this.body,
    required this.score,
    required this.commentCount,
    this.imageNames = const <String>[],
    this.communityName,
    this.isAuthorOnline = false,
  });

  final String id;
  final String authorName;

  /// Contoh: "Fakultas Kedokteran '21".
  final String authorInfo;
  final String timeAgo;
  final String title;

  /// Paragraf dipisah baris kosong. Teks di antara `**` ditebalkan.
  final String body;
  final int score;
  final int commentCount;
  final List<String> imageNames;
  final String? communityName;
  final bool isAuthorOnline;

  /// Data yang dikirim ke form laporan saat utas dilaporkan.
  ReportTarget toReportTarget() => ReportTarget(
        type: ReportTargetType.thread,
        id: id,
        authorName: authorName,
        excerpt: title,
        communityName: communityName,
      );
}
