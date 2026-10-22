// lib/viewmodels/threads_provider.dart
import 'package:flutter/foundation.dart';
import 'package:unand_space/models/thread_post.dart';
import 'package:unand_space/repositories/community_repository.dart';

class ThreadsProvider extends ChangeNotifier {
  ThreadsProvider({required this.repository, required this.communityId}) {
    load();
  }

  final CommunityRepository repository;
  final String communityId;

  List<ThreadPost> threads = const [];
  bool isLoading = true;
  bool isBusy = false;
  String? loadError;
  String? actionError;
  bool _disposed = false;

  ThreadPost? get pinned {
    for (final t in threads) {
      if (t.isPinned) return t;
    }
    return null;
  }

  List<ThreadPost> get regular => threads.where((t) => !t.isPinned).toList();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> load() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      threads = await repository.listThreads(communityId);
    } catch (_) {
      loadError = 'Gagal memuat utas.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pin(String threadId) => _act(
    () => repository.pinThread(communityId, threadId),
    'Gagal menyematkan utas. Coba lagi.',
  );

  Future<bool> unpin(String threadId) => _act(
    () => repository.unpinThread(communityId, threadId),
    'Gagal melepas sematan. Coba lagi.',
  );

  Future<bool> _act(Future<void> Function() action, String fallback) async {
    actionError = null;
    isBusy = true;
    notifyListeners();
    try {
      await action();
      threads = await repository.listThreads(communityId);
      return true;
    } on RepositoryException catch (e) {
      actionError = e.message;
      return false;
    } catch (_) {
      actionError = fallback;
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
