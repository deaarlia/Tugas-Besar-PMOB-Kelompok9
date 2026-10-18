import 'package:unand_space/models/community.dart';

/// Kesalahan yang pesannya boleh ditampilkan langsung ke pengguna.
class RepositoryException implements Exception {
  const RepositoryException(this.message);
  final String message;
}

abstract class CommunityRepository {
  Future<List<Community>> list();
  Future<bool> isNameTaken(String name, {String? excludeId});
  Future<Community> create(CommunityDraft draft);
  Future<Community> update(String id, CommunityDraft draft);
  Future<void> delete(String id);

  // FR-09
  Future<Community> updateRules(String id, String rules);
  Future<List<Moderator>> listModerators(String communityId);
  Future<Moderator> appointModerator(String communityId, String identifier);
  Future<void> revokeModerator(String communityId, String moderatorId);
}
