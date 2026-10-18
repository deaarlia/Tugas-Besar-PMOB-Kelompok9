import 'package:flutter/foundation.dart';
import '../models/community.dart';
import '../repositories/community_repository.dart';

class CommunityListViewModel extends ChangeNotifier {
  final CommunityRepository _repository;

  CommunityListViewModel(this._repository);

  List<Community> _communities = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Community> get communities => _communities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  /// Komunitas yang diikuti pengguna (untuk bagian "Komunitas Saya").
  List<Community> get followedCommunities =>
      _communities.where((c) => c.isFollowing).toList();

  Future<void> fetchCommunities({String? query}) async {
    _isLoading = true;
    _error = null;
    _searchQuery = query ?? '';
    notifyListeners();

    try {
      _communities = await _repository.getCommunities(query: _searchQuery);
    } catch (e) {
      _error = 'Gagal memuat daftar komunitas. Coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gabung / keluar komunitas.
  /// Repository yang mengubah data (isFollowing & memberCount),
  /// lalu provider mengambil ulang daftar terbaru tanpa spinner
  /// supaya semua layar (Explore, Detail, Beranda) ikut ter-update.
  Future<void> toggleFollow(String communityId) async {
    try {
      await _repository.toggleFollowCommunity(communityId);
      _communities = await _repository.getCommunities(query: _searchQuery);
      notifyListeners();
    } catch (e) {
      debugPrint('toggleFollow gagal: $e');
    }
  }
}