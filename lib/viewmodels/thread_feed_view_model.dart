import 'package:flutter/foundation.dart';

import '../data/placeholder_data.dart';
import '../models/thread_sort.dart';
import '../repositories/thread_repository.dart';

class ThreadFeedViewModel extends ChangeNotifier {
  ThreadFeedViewModel(this._repository);

  final ThreadRepository _repository;

  String _query = '';
  String? _selectedCommunityId; // null = semua komunitas
  ThreadSort _sort = ThreadSort.newest;

  String get query => _query;
  String? get selectedCommunityId => _selectedCommunityId;
  ThreadSort get sort => _sort;

  bool get hasActiveFilters =>
      _query.trim().isNotEmpty ||
      _selectedCommunityId != null ||
      _sort != ThreadSort.newest;

  /// Urutan proses: filter komunitas -> cari -> urutkan.
  List<DemoPost> get visibleThreads {
    Iterable<DemoPost> result = _repository.getThreads();

    final String? communityId = _selectedCommunityId;
    if (communityId != null) {
      result = result.where((DemoPost p) => p.communityId == communityId);
    }

    final List<String> terms = _normalize(_query)
        .split(' ')
        .where((String t) => t.isNotEmpty)
        .toList();
    if (terms.isNotEmpty) {
      result = result.where((DemoPost p) {
        final String haystack = _normalize('${p.title} ${p.body}');
        return terms.every(haystack.contains);
      });
    }

        // Belum terjawab = belum ada jawaban/komentar sama sekali.
    if (_sort == ThreadSort.unanswered) {
      result = result.where((DemoPost p) => p.comments == 0);
    }

    final List<DemoPost> list = result.toList();
    switch (_sort) {
      case ThreadSort.newest:
      case ThreadSort.unanswered:
        list.sort((a, b) => a.minutesAgo.compareTo(b.minutesAgo));
      case ThreadSort.popular:
        list.sort((a, b) {
          final int byVotes = b.votes.compareTo(a.votes);
          if (byVotes != 0) return byVotes;
          final int byComments = b.comments.compareTo(a.comments);
          if (byComments != 0) return byComments;
          return a.minutesAgo.compareTo(b.minutesAgo);
        });
    }
    return list;
  }

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  void selectCommunity(String? communityId) {
    if (communityId == _selectedCommunityId) return;
    _selectedCommunityId = communityId;
    notifyListeners();
  }

  void selectSort(ThreadSort value) {
    if (value == _sort) return;
    _sort = value;
    notifyListeners();
  }

  void resetFilters() {
    _query = '';
    _selectedCommunityId = null;
    _sort = ThreadSort.newest;
    notifyListeners();
  }

  static String _normalize(String s) => s
      .replaceAll('**', ' ')
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}