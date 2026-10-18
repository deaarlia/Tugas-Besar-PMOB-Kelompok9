import 'package:flutter/foundation.dart';

import '../data/thread_repository.dart';
import '../models/attachments.dart';
import '../models/thread_comment.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';

enum CommentSort { newest, top }

class ThreadDetailViewModel extends ChangeNotifier {
  ThreadDetailViewModel({
    required this.isFollowed,
    required this.onToggleFollow,
    ThreadPost? thread,
    this.currentUser,
    ThreadRepository? repository,
  }) : _repository = repository ?? ThreadRepository.instance {
    _thread = thread;
  }

  bool isFollowed;
  final VoidCallback onToggleFollow;
  final UserProfile? currentUser;
  final ThreadRepository _repository;
  ThreadPost? _thread;
  List<ThreadComment> _comments = [];
  CommentSort _commentSort = CommentSort.newest;
  String? _errorMessage;
  bool _isLoadingComments = false;
  bool _disposed = false;

  ThreadPost? get thread => _thread;
  String? get errorMessage => _errorMessage;
  bool get isLoadingComments => _isLoadingComments;
  CommentSort get commentSort => _commentSort;
  bool get isOwnThread =>
      currentUser != null && _thread?.authorName == currentUser!.name;

  List<ThreadComment> get comments {
    final available = _comments
        .where(
          (comment) =>
              !comment.isDeleted ||
              _comments.any((child) => child.parentId == comment.id),
        )
        .toList();
    int compare(ThreadComment first, ThreadComment second) {
      if (_commentSort == CommentSort.top) {
        final scoreComparison = second.score.compareTo(first.score);
        if (scoreComparison != 0) return scoreComparison;
      }
      return second.createdAt.compareTo(first.createdAt);
    }

    final ordered = <ThreadComment>[];
    void visit(ThreadComment comment) {
      ordered.add(comment);
      final replies =
          available.where((item) => item.parentId == comment.id).toList()
            ..sort(compare);
      for (final reply in replies) {
        visit(reply);
      }
    }

    final roots =
        available.where((comment) => comment.parentId == null).toList()
          ..sort(compare);
    for (final root in roots) {
      visit(root);
    }
    return List.unmodifiable(ordered);
  }

  List<ThreadComment> get rootComments =>
      List.unmodifiable(comments.where((comment) => comment.parentId == null));

  List<ThreadComment> repliesFor(ThreadComment comment) =>
      List.unmodifiable(comments.where((item) => item.parentId == comment.id));

  int get commentCount =>
      _comments.where((comment) => !comment.isDeleted).length;

  void toggleFollow() {
    isFollowed = !isFollowed;
    onToggleFollow();
    _notifyListeners();
  }

  Future<void> loadComments() async {
    final thread = _thread;
    if (thread == null) return;
    _isLoadingComments = true;
    _errorMessage = null;
    _notifyListeners();
    try {
      _comments = await _repository.fetchComments(thread.id);
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingComments = false;
      _notifyListeners();
    }
  }

  void setCommentSort(CommentSort sort) {
    _commentSort = sort;
    _notifyListeners();
  }

  Future<String?> addComment(
    String content, {
    String? parentId,
    List<Uint8List> photos = const [],
    DocumentAttachment? document,
  }) async {
    final thread = _thread;
    final user = currentUser;
    if (thread == null || user == null) return 'Data pengguna tidak tersedia.';
    try {
      await _repository.addComment(
        threadId: thread.id,
        authorName: user.name,
        authorBadge: user.badge,
        content: content,
        parentId: parentId,
        photos: photos,
        document: document,
      );
      _comments = await _repository.fetchComments(thread.id);
      _refreshThread();
      _notifyListeners();
      return null;
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> editComment(ThreadComment comment, String content) async {
    final user = currentUser;
    final thread = _thread;
    if (user == null || thread == null) return 'Data pengguna tidak tersedia.';
    try {
      await _repository.updateComment(
        threadId: thread.id,
        commentId: comment.id,
        authorName: user.name,
        content: content,
      );
      _comments = await _repository.fetchComments(thread.id);
      _notifyListeners();
      return null;
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> deleteComment(ThreadComment comment) async {
    final user = currentUser;
    final thread = _thread;
    if (user == null || thread == null) return 'Data pengguna tidak tersedia.';
    try {
      await _repository.deleteComment(
        threadId: thread.id,
        commentId: comment.id,
        authorName: user.name,
      );
      _comments = await _repository.fetchComments(thread.id);
      _refreshThread();
      _notifyListeners();
      return null;
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> voteComment(ThreadComment comment, int vote) async {
    final user = currentUser;
    final thread = _thread;
    if (user == null || thread == null) return 'Data pengguna tidak tersedia.';
    try {
      await _repository.voteComment(
        threadId: thread.id,
        commentId: comment.id,
        userName: user.name,
        vote: vote,
      );
      _comments = await _repository.fetchComments(thread.id);
      _notifyListeners();
      return null;
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> voteThread(int vote) async {
    final user = currentUser;
    final thread = _thread;
    if (user == null || thread == null) return 'Data pengguna tidak tersedia.';
    try {
      await _repository.voteThread(
        threadId: thread.id,
        userName: user.name,
        vote: vote,
      );
      _refreshThread();
      _notifyListeners();
      return null;
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> acceptAnswer(ThreadComment comment) async {
    final user = currentUser;
    final thread = _thread;
    if (user == null || thread == null) return 'Data pengguna tidak tersedia.';
    try {
      await _repository.acceptAnswer(
        threadId: thread.id,
        commentId: comment.id,
        authorName: user.name,
      );
      _refreshThread();
      _notifyListeners();
      return null;
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
    }
  }

  void updateThread(ThreadPost thread) {
    _thread = thread;
    _notifyListeners();
  }

  void _refreshThread() {
    final id = _thread?.id;
    if (id == null) return;
    for (final thread in _repository.threads) {
      if (thread.id == id) {
        _thread = thread;
        return;
      }
    }
  }

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
