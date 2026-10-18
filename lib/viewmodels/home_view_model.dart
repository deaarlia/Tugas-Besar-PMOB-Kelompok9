import 'package:flutter/foundation.dart';

import '../data/thread_repository.dart';
import '../models/thread_post.dart';

enum ViewStatus { loading, success, error }

enum FeedFilter { terbaru, semuaKomunitas, terpopuler, belumTerjawab }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({ThreadRepository? repository})
    : _repository = repository ?? ThreadRepository.instance;

  static const int pageSize = 10;

  final ThreadRepository _repository;
  ViewStatus _status = ViewStatus.loading;
  List<ThreadPost> _threads = [];
  String _errorMessage = '';
  int _tabIndex = 0;
  FeedFilter _filter = FeedFilter.terbaru;
  String _query = '';
  final Set<String> _followed = {};
  bool _disposed = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _loadMoreError;

  ViewStatus get status => _status;
  String get errorMessage => _errorMessage;
  int get tabIndex => _tabIndex;
  FeedFilter get filter => _filter;
  String get query => _query;
  bool get simulateError => _repository.simulateError;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get loadMoreError => _loadMoreError;
  Set<String> get followed => Set.unmodifiable(_followed);

  List<ThreadPost> get visibleThreads {
    var list = List.of(_threads);

    if (_tabIndex == 1) {
      list = list
          .where((thread) =>
              !thread.isAnonymous && _followed.contains(thread.authorName))
          .toList();
    }

    if (_query.isNotEmpty) {
      final query = _query.toLowerCase();
      list = list
          .where(
            (thread) =>
                thread.title.toLowerCase().contains(query) ||
                thread.content.toLowerCase().contains(query) ||
                thread.topics.any((topic) => topic.toLowerCase().contains(query)),
          )
          .toList();
    }

    switch (_filter) {
      case FeedFilter.terpopuler:
        list.sort((a, b) => b.upvotes.compareTo(a.upvotes));
      case FeedFilter.belumTerjawab:
        list = list.where((thread) => thread.comments == 0).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case FeedFilter.terbaru:
      case FeedFilter.semuaKomunitas:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  String get emptyMessage {
    if (_query.isNotEmpty) return 'Tidak ada utas yang cocok dengan "$_query".';
    if (_tabIndex == 1) return 'Belum ada utas dari akun yang kamu ikuti.';
    if (_filter == FeedFilter.belumTerjawab) {
      return 'Semua utas sudah ada tanggapan.';
    }
    return 'Belum ada utas. Jadilah yang pertama!';
  }

  Future<void> loadThreads() async {
    if (_status != ViewStatus.loading) {
      _status = ViewStatus.loading;
      _notifyListeners();
    }
    try {
      final threads = await _repository.fetchThreads(limit: pageSize + 1);
      if (_disposed) return;
      _threads = threads.take(pageSize).toList();
      _hasMore = threads.length > pageSize;
      _status = ViewStatus.success;
      _notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = ViewStatus.error;
      _notifyListeners();
    }

  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _status != ViewStatus.success) return;
    _isLoadingMore = true;
    _loadMoreError = null;
    _notifyListeners();
    try {
      final nextPage = await _repository.fetchThreads(
        offset: _threads.length,
        limit: pageSize + 1,
      );
      if (_disposed) return;
      _threads.addAll(nextPage.take(pageSize));
      _hasMore = nextPage.length > pageSize;
    } catch (error) {
      if (_disposed) return;
      _loadMoreError = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingMore = false;
      _notifyListeners();
    }
  }

  void setQuery(String query) {
    _query = query.trim();
    _notifyListeners();
  }

  void selectTab(int index) {
    _tabIndex = index;
    _notifyListeners();
  }

  void selectFilter(FeedFilter filter) {
    _filter = filter;
    _notifyListeners();
  }

  void toggleFollow(String authorName) {
    if (!_followed.remove(authorName)) _followed.add(authorName);
    _notifyListeners();
  }

  void toggleSimulateError() {
    _repository.simulateError = !_repository.simulateError;
    _notifyListeners();
  }

  void onThreadCreated() {
    refreshThreads();
    _tabIndex = 0;
    _filter = FeedFilter.terbaru;
    _query = '';
    _notifyListeners();
  }

  void refreshThreads() {
    final allThreads = _repository.threads;
    _threads = allThreads.take(pageSize).toList();
    _hasMore = allThreads.length > pageSize;
    _status = ViewStatus.success;
    _notifyListeners();
  }

  Future<String?> voteThread({
    required String threadId,
    required String userName,
    required int vote,
  }) async {
    try {
      await _repository.voteThread(
        threadId: threadId,
        userName: userName,
        vote: vote,
      );
      refreshThreads();
      return null;
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
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
