import 'dart:typed_data';

import 'attachments.dart';

/// Model satu utas/postingan forum.
class ThreadPost {
  final String id;
  final String title;
  final String content;

  /// Topik (opsional): hanya untuk pengelompokan/pencarian, tidak ditampilkan di kartu.
  final List<String> topics;

  final String authorName;
  final String authorBadge;
  final bool isAnonymous;

  /// Foto asli yang dipilih dari galeri.
  final List<Uint8List> photos;

  /// Jumlah foto placeholder untuk data contoh (seed) yang tidak punya berkas.
  final int placeholderPhotoCount;

  final String? linkUrl;
  final PollDraft? poll; // mockup
  final DocumentAttachment? document;

  final int upvotes;
  final int comments;
  final DateTime createdAt;

  const ThreadPost({
    required this.id,
    required this.title,
    required this.content,
    this.topics = const [],
    required this.authorName,
    required this.authorBadge,
    required this.isAnonymous,
    this.photos = const [],
    this.placeholderPhotoCount = 0,
    this.linkUrl,
    this.poll,
    this.document,
    this.upvotes = 0,
    this.comments = 0,
    required this.createdAt,
  });

  int get photoCount => photos.length + placeholderPhotoCount;

  /// Mode anonim: nama asli tidak ditampilkan.
  String get displayAuthor => isAnonymous ? 'Mahasiswa Anonim' : authorName;

  /// Waktu relatif: "Baru saja", "15 mnt lalu", "3 jam lalu", "2 hari lalu".
  String get timeLabel {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}
