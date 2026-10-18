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
}
