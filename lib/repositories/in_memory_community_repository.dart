// lib/repositories/in_memory_community_repository.dart
import 'package:unand_space/models/community.dart';
import 'package:unand_space/repositories/community_repository.dart';

/// Hanya untuk menguji UI. Ganti dengan implementasi REST API nanti.
class InMemoryCommunityRepository implements CommunityRepository {
  final List<Community> _items = [];
  final Map<String, List<Moderator>> _moderators = {};
  int _seq = 0;
  int _modSeq = 0;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<Community>> list() async {
    await _delay();
    return List.unmodifiable(_items.reversed); // terbaru di atas
  }

  @override
  Future<bool> isNameTaken(String name, {String? excludeId}) async {
    await _delay();
    return _items.any(
      (c) => c.id != excludeId && c.name.toLowerCase() == name.toLowerCase(),
    );
  }

  @override
  Future<Community> create(CommunityDraft draft) async {
    await _delay();
    final c = Community(
      id: 'c${++_seq}',
      name: draft.name,
      description: draft.description,
      category: draft.category,
      isPublic: draft.isPublic,
      iconUrl: draft.iconPath,
      coverUrl: draft.coverPath,
      rules: draft.rules,
      createdAt: DateTime.now(),
      creatorName: 'Anda', // placeholder: seharusnya dari data pengguna login
      memberCount: 1, // pembuat otomatis menjadi anggota
      myRole: CommunityRole.creator,
    );
    _items.add(c);
    _moderators[c.id] = [
      Moderator(id: 'm${++_modSeq}', name: c.creatorName!, isCreator: true),
    ];
    return c;
  }

  @override
  Future<Community> update(String id, CommunityDraft draft) async {
    await _delay();
    final i = _items.indexWhere((c) => c.id == id);
    final old = _items[i];
    final c = Community(
      id: id,
      name: draft.name,
      description: draft.description,
      category: draft.category,
      isPublic: draft.isPublic,
      iconUrl: draft.iconPath ?? old.iconUrl,
      coverUrl: draft.coverPath ?? old.coverUrl,
      rules: old.rules,
      createdAt: old.createdAt,
      creatorName: old.creatorName,
      memberCount: old.memberCount,
      myRole: old.myRole,
    );
    _items[i] = c;
    return c;
  }

  @override
  Future<void> delete(String id) async {
    await _delay();
    _items.removeWhere((c) => c.id == id);
    _moderators.remove(id);
  }

  // ---- FR-09 ----

  @override
  Future<Community> updateRules(String id, String rules) async {
    await _delay();
    final i = _items.indexWhere((c) => c.id == id);
    final old = _items[i];
    final c = Community(
      id: old.id,
      name: old.name,
      description: old.description,
      category: old.category,
      isPublic: old.isPublic,
      iconUrl: old.iconUrl,
      coverUrl: old.coverUrl,
      rules: rules,
      createdAt: old.createdAt,
      creatorName: old.creatorName,
      memberCount: old.memberCount,
      myRole: old.myRole,
    );
    _items[i] = c;
    return c;
  }

  @override
  Future<List<Moderator>> listModerators(String communityId) async {
    await _delay();
    return List.unmodifiable(_moderators[communityId] ?? const []);
  }

  @override
  Future<Moderator> appointModerator(
    String communityId,
    String identifier,
  ) async {
    await _delay();
    final list = _moderators.putIfAbsent(communityId, () => []);
    final exists = list.any(
      (m) => m.name.toLowerCase() == identifier.toLowerCase(),
    );
    if (exists) {
      throw const RepositoryException('Pengguna ini sudah menjadi moderator');
    }
    // Placeholder: backend asli harus mencari pengguna dan menolak jika tidak ditemukan.
    final m = Moderator(id: 'm${++_modSeq}', name: identifier);
    list.add(m);
    return m;
  }

  @override
  Future<void> revokeModerator(String communityId, String moderatorId) async {
    await _delay();
    final list = _moderators[communityId] ?? [];
    final target = list.where((m) => m.id == moderatorId);
    if (target.isEmpty) {
      throw const RepositoryException('Moderator tidak ditemukan');
    }
    if (target.first.isCreator) {
      throw const RepositoryException('Pembuat komunitas tidak dapat dicabut');
    }
    list.removeWhere((m) => m.id == moderatorId);
  }
}
