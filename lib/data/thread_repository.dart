import 'dart:typed_data';

import 'package:characters/characters.dart';

import '../models/attachments.dart';
import '../models/thread_comment.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';

/// Exception khusus untuk kegagalan membuat/mengambil utas.
class ThreadException implements Exception {
  final String message;
  const ThreadException(this.message);

  @override
  String toString() => message;
}

/// Data layer (simulasi, belum memakai backend).
/// Singleton agar Home dan Form memakai sumber data yang sama.
class ThreadRepository {
  ThreadRepository._();
  static final ThreadRepository instance = ThreadRepository._();

  /// true -> createThread selalu gagal (untuk demo error state).
  bool simulateError = false;

  static DateTime _ago(Duration d) => DateTime.now().subtract(d);

  final List<ThreadPost> _threads = [
    ThreadPost(
      id: 'T001',
      title: 'Adakah Rekomendasi Dosen Pembimbing untuk Skripsi Machine Learning di Teknik Komputer?',
      content: 'Halo teman-teman semua! Saya berencana mengambil topik Machine Learning untuk deteksi penyakit daun kelapa sawit di Sumbar. Kira-kira dosen pembimbing laboratorium mana yang cocok?',
      authorName: 'Rafi Kurniawan',
      authorBadge: "FTI '22",
      isAnonymous: false,
      upvotes: 42,
      comments: 18,
      createdAt: _ago(const Duration(minutes: 15)),
    ),
    ThreadPost(
      id: 'T002',
      title: 'Kondisi Parkiran Gedung Kuliah A Jam 08.00 Pagi Ini Sangat Penuh',
      content: 'Teman-teman yang ada kuliah jam 08.40 di GKB sebaiknya parkir di depan gedung PKM atau dekat rektorat. Lahan parkir motor GKB sudah meluber sampai ke badan jalan akses atas.',
      authorName: 'Anonim',
      authorBadge: '',
      isAnonymous: true,
      placeholderPhotoCount: 3,
      upvotes: 89,
      comments: 34,
      createdAt: _ago(const Duration(hours: 1)),
    ),
    ThreadPost(
      id: 'T003',
      title: 'Prosedur Pengajuan Cuti Akademik Semester Ganjil via SIA Unand',
      content: 'Bagi yang perlu menunda semester karena magang atau alasan lainnya, berikut alur permohonan surat cuti akademik lewat laman SIA.',
      authorName: 'Aisyah Putri',
      authorBadge: "FK '21",
      isAnonymous: false,
      upvotes: 120,
      comments: 45,
      createdAt: _ago(const Duration(hours: 3)),
    ),
  ];

  final Map<String, List<ThreadComment>> _comments = {
    'T001': [
      ThreadComment(
        id: 'C001',
        threadId: 'T001',
        authorName: 'Aisyah Putri',
        authorBadge: "FK '21",
        content: 'Coba cek lab machine learning di FTI. Beberapa dosen di sana fokus ke computer vision.',
        createdAt: _ago(const Duration(minutes: 8)),
        score: 12,
      ),
      ThreadComment(
        id: 'C002',
        threadId: 'T001',
        authorName: 'Rafi Kurniawan',
        authorBadge: "FTI '22",
        content: 'Terima kasih, nanti saya coba hubungi labnya.',
        createdAt: _ago(const Duration(minutes: 4)),
        parentId: 'C001',
        depth: 1,
        score: 3,
      ),
    ],
  };
  final Map<String, Map<String, int>> _threadVotes = {};
  final Map<String, Map<String, int>> _commentVotes = {};
  int _commentIdSequence = 0;

  List<ThreadPost> get threads => List.unmodifiable(
    _threads
        .where((thread) => !thread.isDeleted)
        .map(
          (thread) => thread.copyWith(comments: _activeCommentCount(thread.id)),
        ),
  );

  int _activeCommentCount(String threadId) =>
      (_comments[threadId] ?? const <ThreadComment>[])
          .where((comment) => !comment.isDeleted)
          .length;

  Future<List<ThreadPost>> fetchThreads({
    int offset = 0,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final available = threads;
    if (offset >= available.length) return const [];
    return List.unmodifiable(available.skip(offset).take(limit));
  }

  Future<ThreadPost> createThread({
    required String title,
    required String content,
    required List<String> topics,
    required List<Uint8List> photos,
    String? linkUrl,
    PollDraft? poll,
    DocumentAttachment? document,
    required UserProfile author,
    required bool isAnonymous,
    String community = 'Umum',
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi request
    if (simulateError) {
      throw const ThreadException(
        'Gagal mengirim utas. Periksa koneksi internet.',
      );
    }
    final thread = ThreadPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      topics: List.unmodifiable(topics),
      authorName: author.name,
      authorBadge: author.badge,
      isAnonymous: isAnonymous,
      community: community,
      photos: List.unmodifiable(photos),
      linkUrl: linkUrl,
      poll: poll,
      document: document,
      createdAt: DateTime.now(),
    );
    _threads.insert(0, thread);
    return thread;
  }

  Future<ThreadPost> updateThread({
    required String threadId,
    required String authorName,
    required String title,
    required String content,
    required List<String> topics,
    required List<Uint8List> photos,
    required bool isAnonymous,
    required String community,
    DocumentAttachment? document,
    bool clearDocument = false,
  }) async {
    final index = _threads.indexWhere((thread) => thread.id == threadId);
    if (index < 0 || _threads[index].isDeleted) {
      throw const ThreadException('Utas tidak ditemukan atau sudah dihapus.');
    }
    final existing = _threads[index];
    if (existing.authorName != authorName) {
      throw const ThreadException('Kamu hanya dapat mengubah utas milikmu.');
    }
    final updated = existing.copyWith(
      title: title,
      content: content,
      topics: List.unmodifiable(topics),
      photos: List.unmodifiable(photos),
      isAnonymous: isAnonymous,
      community: community,
      document: document,
      clearDocument: clearDocument,
      isEdited: true,
      updatedAt: DateTime.now(),
    );
    _threads[index] = updated;
    return updated;
  }

  Future<void> deleteThread({
    required String threadId,
    required String authorName,
  }) async {
    final index = _threads.indexWhere((thread) => thread.id == threadId);
    if (index < 0 || _threads[index].isDeleted) {
      throw const ThreadException('Utas tidak ditemukan atau sudah dihapus.');
    }
    final thread = _threads[index];
    if (thread.authorName != authorName) {
      throw const ThreadException('Kamu hanya dapat menghapus utas milikmu.');
    }
    _threads[index] = thread.copyWith(isDeleted: true);
  }

  Future<int> voteThread({
    required String threadId,
    required String userName,
    required int vote,
  }) async {
    final index = _threads.indexWhere((thread) => thread.id == threadId);
    if (index < 0 || _threads[index].isDeleted) {
      throw const ThreadException('Utas tidak ditemukan.');
    }
    final thread = _threads[index];
    if (thread.authorName == userName) {
      throw const ThreadException(
        'Kamu tidak dapat memberi suara pada utasmu.',
      );
    }
    final userVotes = _threadVotes.putIfAbsent(threadId, () => {});
    final previousVote = userVotes[userName] ?? 0;
    final nextVote = previousVote == vote ? 0 : vote;
    userVotes[userName] = nextVote;
    final score = thread.score + nextVote - previousVote;
    final upvoteCount =
        thread.upvoteCount +
        (nextVote == 1 ? 1 : 0) -
        (previousVote == 1 ? 1 : 0);
    final downvoteCount =
        thread.downvoteCount +
        (nextVote == -1 ? 1 : 0) -
        (previousVote == -1 ? 1 : 0);
    _threads[index] = thread.copyWith(
      upvotes: score,
      upvoteCount: upvoteCount,
      downvoteCount: downvoteCount,
      myVote: nextVote,
    );
    return score;
  }

  Future<List<ThreadComment>> fetchComments(String threadId) async {
    final comments = _comments[threadId] ?? const <ThreadComment>[];
    return List.unmodifiable(comments);
  }

  Future<ThreadComment> addComment({
    required String threadId,
    required String authorName,
    required String authorBadge,
    required String content,
    List<Uint8List> photos = const [],
    DocumentAttachment? document,
    String? parentId,
  }) async {
    if (content.trim().characters.length > 500) {
      throw const ThreadException('Komentar maksimal 500 karakter.');
    }
    final thread = _threads.firstWhere(
      (item) => item.id == threadId && !item.isDeleted,
      orElse: () => throw const ThreadException('Utas tidak ditemukan.'),
    );
    final comments = _comments.putIfAbsent(threadId, () => []);
    if (parentId != null) {
      final parentIndex = comments.indexWhere(
        (comment) => comment.id == parentId && !comment.isDeleted,
      );
      if (parentIndex < 0) {
        throw const ThreadException('Komentar yang dibalas tidak ditemukan.');
      }
      if (comments[parentIndex].depth >= 4) {
        throw const ThreadException(
          'Balasan hanya dapat dibuat sampai lima tingkat.',
        );
      }
    }
    final comment = ThreadComment(
      id: 'C${DateTime.now().microsecondsSinceEpoch}_${_commentIdSequence++}',
      threadId: threadId,
      authorName: authorName,
      authorBadge: authorBadge,
      content: content.trim(),
      parentId: parentId,
      photos: List.unmodifiable(photos),
      document: document,
      depth: parentId == null
          ? 0
          : comments.firstWhere((comment) => comment.id == parentId).depth + 1,
      createdAt: DateTime.now(),
    );
    comments.add(comment);
    final index = _threads.indexWhere((item) => item.id == thread.id);
    _threads[index] = thread.copyWith(comments: _activeCommentCount(threadId));
    return comment;
  }

  Future<ThreadComment> updateComment({
    required String threadId,
    required String commentId,
    required String authorName,
    required String content,
  }) async {
    final comments = _comments[threadId];
    final index = comments?.indexWhere((item) => item.id == commentId) ?? -1;
    if (comments == null || index < 0 || comments[index].isDeleted) {
      throw const ThreadException('Komentar tidak ditemukan.');
    }
    if (comments[index].authorName != authorName) {
      throw const ThreadException(
        'Kamu hanya dapat mengubah komentarmu sendiri.',
      );
    }
    final updated = comments[index].copyWith(
      content: content.trim(),
      isEdited: true,
    );
    comments[index] = updated;
    return updated;
  }

  Future<void> deleteComment({
    required String threadId,
    required String commentId,
    required String authorName,
  }) async {
    final comments = _comments[threadId];
    final index = comments?.indexWhere((item) => item.id == commentId) ?? -1;
    if (comments == null || index < 0 || comments[index].isDeleted) {
      throw const ThreadException('Komentar tidak ditemukan.');
    }
    final comment = comments[index];
    if (comment.authorName != authorName) {
      throw const ThreadException(
        'Kamu hanya dapat menghapus komentarmu sendiri.',
      );
    }
    comments[index] = comment.copyWith(isDeleted: true);
    final threadIndex = _threads.indexWhere((item) => item.id == threadId);
    if (threadIndex >= 0) {
      final thread = _threads[threadIndex];
      _threads[threadIndex] = thread.copyWith(
        comments: _activeCommentCount(threadId),
        clearAcceptedComment: thread.acceptedCommentId == commentId,
      );
    }
  }

  Future<int> voteComment({
    required String threadId,
    required String commentId,
    required String userName,
    required int vote,
  }) async {
    final comments = _comments[threadId];
    final index = comments?.indexWhere((item) => item.id == commentId) ?? -1;
    if (comments == null || index < 0 || comments[index].isDeleted) {
      throw const ThreadException('Komentar tidak ditemukan.');
    }
    final comment = comments[index];
    if (comment.authorName == userName) {
      throw const ThreadException(
        'Kamu tidak dapat memberi suara pada komentarmu.',
      );
    }
    final key = '$threadId:$commentId';
    final userVotes = _commentVotes.putIfAbsent(key, () => {});
    final previousVote = userVotes[userName] ?? 0;
    final nextVote = previousVote == vote ? 0 : vote;
    userVotes[userName] = nextVote;
    final score = comment.score + nextVote - previousVote;
    final upvoteCount =
        comment.upvoteCount +
        (nextVote == 1 ? 1 : 0) -
        (previousVote == 1 ? 1 : 0);
    final downvoteCount =
        comment.downvoteCount +
        (nextVote == -1 ? 1 : 0) -
        (previousVote == -1 ? 1 : 0);
    comments[index] = comment.copyWith(
      score: score,
      upvoteCount: upvoteCount,
      downvoteCount: downvoteCount,
      myVote: nextVote,
    );
    return score;
  }

  Future<void> acceptAnswer({
    required String threadId,
    required String commentId,
    required String authorName,
  }) async {
    final threadIndex = _threads.indexWhere(
      (item) => item.id == threadId && !item.isDeleted,
    );
    if (threadIndex < 0) {
      throw const ThreadException('Utas tidak ditemukan.');
    }
    final thread = _threads[threadIndex];
    if (thread.authorName != authorName) {
      throw const ThreadException(
        'Hanya penulis utas yang dapat memilih jawaban terbaik.',
      );
    }
    final comments = _comments[threadId] ?? const <ThreadComment>[];
    if (!comments.any(
      (comment) => comment.id == commentId && !comment.isDeleted,
    )) {
      throw const ThreadException('Komentar tidak ditemukan.');
    }
    _threads[threadIndex] = thread.copyWith(acceptedCommentId: commentId);
  }
}
