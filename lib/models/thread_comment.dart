import 'dart:typed_data';

import 'attachments.dart';

class ThreadComment {
  const ThreadComment({
    required this.id,
    required this.threadId,
    required this.authorName,
    required this.authorBadge,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.depth = 0,
    this.photos = const [],
    this.document,
    this.score = 0,
    int? upvoteCount,
    int? downvoteCount,
    this.myVote = 0,
    this.isEdited = false,
    this.isDeleted = false,
  }) : upvoteCount = upvoteCount ?? (score > 0 ? score : 0),
       downvoteCount = downvoteCount ?? (score < 0 ? -score : 0);

  final String id;
  final String threadId;
  final String authorName;
  final String authorBadge;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final int depth;
  final List<Uint8List> photos;
  final DocumentAttachment? document;
  final int score;
  final int upvoteCount;
  final int downvoteCount;
  final int myVote;
  final bool isEdited;
  final bool isDeleted;

  String get timeLabel {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inDays < 1) return '${difference.inHours} jam lalu';
    return '${difference.inDays} hari lalu';
  }

  ThreadComment copyWith({
    String? content,
    List<Uint8List>? photos,
    DocumentAttachment? document,
    bool clearDocument = false,
    int? score,
    int? upvoteCount,
    int? downvoteCount,
    int? myVote,
    bool? isEdited,
    bool? isDeleted,
  }) {
    return ThreadComment(
      id: id,
      threadId: threadId,
      authorName: authorName,
      authorBadge: authorBadge,
      content: content ?? this.content,
      createdAt: createdAt,
      parentId: parentId,
      depth: depth,
      photos: photos ?? this.photos,
      document: clearDocument ? null : (document ?? this.document),
      score: score ?? this.score,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      downvoteCount: downvoteCount ?? this.downvoteCount,
      myVote: myVote ?? this.myVote,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
