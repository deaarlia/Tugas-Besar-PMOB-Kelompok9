import 'report_target.dart';

/// Model tampilan komentar.
///
/// TODO Modul 3: ganti dengan model Reply/Comment dari REST API.
class Comment {
  const Comment({
    required this.id,
    required this.authorName,
    required this.authorInfo,
    required this.timeAgo,
    required this.body,
    required this.score,
    this.authorTag,
    this.isThreadAuthor = false,
    this.isBestAnswer = false,
    this.replies = const <Comment>[],
  });

  final String id;
  final String authorName;
  final String authorInfo;
  final String timeAgo;
  final String body;
  final int score;

  /// Label organisasi, contoh "BEM KM Unand".
  final String? authorTag;
  final bool isThreadAuthor;
  final bool isBestAnswer;
  final List<Comment> replies;

  /// Data yang dikirim ke form laporan saat komentar dilaporkan.
  ReportTarget toReportTarget() => ReportTarget(
        type: ReportTargetType.comment,
        id: id,
        authorName: authorName,
        excerpt: _excerpt(body),
      );

  static String _excerpt(String text) {
    final String flat =
        text.replaceAll('**', '').replaceAll(RegExp(r'\s+'), ' ').trim();
    return flat.length <= 140 ? flat : '${flat.substring(0, 140).trimRight()}...';
  }
}