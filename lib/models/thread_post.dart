// lib/models/thread_post.dart
/// Model utas SEMENTARA untuk FR-10. Ganti dengan model utas Modul 3 saat merge.
class ThreadPost {
  const ThreadPost({
    required this.id,
    required this.communityId,
    required this.authorName,
    required this.body,
    required this.createdAt,
    this.isAnonymous = false,
    this.upvotes = 0,
    this.commentCount = 0,
    this.isPinned = false,
    this.pinnedAt,
  });

  final String id;
  final String communityId;
  final String authorName;
  final String body;
  final DateTime createdAt;
  final bool isAnonymous;
  final int upvotes;
  final int commentCount;
  final bool isPinned;
  final DateTime? pinnedAt;

  String get displayAuthor => isAnonymous ? 'Mahasiswa Anonim' : authorName;

  ThreadPost withPinned(bool pinned) => ThreadPost(
    id: id,
    communityId: communityId,
    authorName: authorName,
    body: body,
    createdAt: createdAt,
    isAnonymous: isAnonymous,
    upvotes: upvotes,
    commentCount: commentCount,
    isPinned: pinned,
    pinnedAt: pinned ? DateTime.now() : null,
  );
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
  final String community;

  /// Foto asli yang dipilih dari galeri.
  final List<Uint8List> photos;

  /// Jumlah foto placeholder untuk data contoh (seed) yang tidak punya berkas.
  final int placeholderPhotoCount;

  final String? linkUrl;
  final PollDraft? poll; // mockup
  final DocumentAttachment? document;

  final int upvotes;
  final int upvoteCount;
  final int downvoteCount;
  final int comments;
  final int myVote;
  final bool isEdited;
  final bool isDeleted;
  final String? acceptedCommentId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ThreadPost({
    required this.id,
    required this.title,
    required this.content,
    this.topics = const [],
    required this.authorName,
    required this.authorBadge,
    required this.isAnonymous,
    this.community = 'Umum',
    this.photos = const [],
    this.placeholderPhotoCount = 0,
    this.linkUrl,
    this.poll,
    this.document,
    this.upvotes = 0,
    int? upvoteCount,
    int? downvoteCount,
    this.comments = 0,
    this.myVote = 0,
    this.isEdited = false,
    this.isDeleted = false,
    this.acceptedCommentId,
    required this.createdAt,
    this.updatedAt,
  }) : upvoteCount = upvoteCount ?? (upvotes > 0 ? upvotes : 0),
       downvoteCount = downvoteCount ?? (upvotes < 0 ? -upvotes : 0);

  int get photoCount => photos.length + placeholderPhotoCount;
  int get score => upvotes;

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

  ThreadPost copyWith({
    String? title,
    String? content,
    List<String>? topics,
    String? community,
    List<Uint8List>? photos,
    int? upvotes,
    int? upvoteCount,
    int? downvoteCount,
    int? comments,
    int? myVote,
    bool? isAnonymous,
    bool? isEdited,
    bool? isDeleted,
    String? acceptedCommentId,
    bool clearAcceptedComment = false,
    DocumentAttachment? document,
    bool clearDocument = false,
    DateTime? updatedAt,
  }) {
    return ThreadPost(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      topics: topics ?? this.topics,
      authorName: authorName,
      authorBadge: authorBadge,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      community: community ?? this.community,
      photos: photos ?? this.photos,
      placeholderPhotoCount: placeholderPhotoCount,
      linkUrl: linkUrl,
      poll: poll,
      document: clearDocument ? null : (document ?? this.document),
      upvotes: upvotes ?? this.upvotes,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      downvoteCount: downvoteCount ?? this.downvoteCount,
      comments: comments ?? this.comments,
      myVote: myVote ?? this.myVote,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      acceptedCommentId: clearAcceptedComment
          ? null
          : (acceptedCommentId ?? this.acceptedCommentId),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
main
}
