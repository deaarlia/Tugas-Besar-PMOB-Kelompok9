
// lib/repositories/community_repository.dart
import 'package:unand_space/models/community.dart';
import 'package:unand_space/models/report.dart';
import 'package:unand_space/models/thread_post.dart';


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

  // FR-10
  Future<List<ThreadPost>> listThreads(String communityId);
  Future<void> pinThread(String communityId, String threadId);
  Future<void> unpinThread(String communityId, String threadId);

  // FR-11
  Future<List<Report>> listReports(String communityId);
  Future<void> rejectReport(String communityId, String reportId);
  Future<void> deleteReportedContent(String communityId, String reportId);
}
