import '../models/community.dart';
import '../models/report.dart'; // Jika dibutuhkan

abstract class CommunityRepository {
  Future<List<Community>> getCommunities({String? query});
  Future<Community?> getCommunityById(String id);
  Future<bool> toggleFollowCommunity(String communityId);
}

class InMemoryCommunityRepository implements CommunityRepository {
  final List<Community> _communities = [
    const Community(
      id: 'comm-1',
      name: 'Umum',
      description: 'Wadah diskusi umum mahasiswa Universitas Andalas.',
      rules: ['Gunakan bahasa yang sopan.', 'Dilarang beriklan/spam.'],
      memberCount: 1250,
      isFollowing: true,
    ),
    const Community(
      id: 'comm-2',
      name: 'Informatika FTI',
      description: 'Komunitas diskusi seputar perkuliahan & praktikum Informatika.',
      rules: ['Gunakan tagar matkul jika bertanya.', 'Hargai pendapat sesama.'],
      memberCount: 450,
      isFollowing: false,
    ),
    const Community(
      id: 'comm-3',
      name: 'Advokasi & BEM',
      description: 'Pusat informasi keluhan UKT, beasiswa, dan birokrasi kampus.',
      rules: ['Sertakan bukti konkrit jika melapor.', 'No hoaks.'],
      memberCount: 890,
      isFollowing: false,
    ),
  ];

  @override
  Future<List<Community>> getCommunities({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 400)); // Simulasi latency
    if (query == null || query.trim().isEmpty) {
      return List.unmodifiable(_communities);
    }
    final q = query.toLowerCase().trim();
    return _communities
        .where((c) => c.name.toLowerCase().contains(q) || c.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<Community?> getCommunityById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _communities.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> toggleFollowCommunity(String communityId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _communities.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      final current = _communities[index];
      final newStatus = !current.isFollowing;
      _communities[index] = current.copyWith(
        isFollowing: newStatus,
        memberCount: newStatus ? current.memberCount + 1 : current.memberCount - 1,
      );
      return newStatus;
    }
    return false;
  }
}