// lib/providers/moderators_provider.dart
import 'package:flutter/foundation.dart';
import 'package:tugas_pmob/models/community.dart';
import 'package:tugas_pmob/repositories/community_repository.dart';

class ModeratorsProvider extends ChangeNotifier {
  ModeratorsProvider({required this.repository, required this.communityId}) {
    load();
  }

  final CommunityRepository repository;
  final String communityId;

  List<Moderator> moderators = const [];
  bool isLoading = true;
  bool isBusy = false;
  String? loadError;
  String? identifierError;
  String? actionError;

  Future<void> load() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      moderators = await repository.listModerators(communityId);
    } catch (_) {
      loadError = 'Gagal memuat daftar moderator.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearIdentifierError() {
    if (identifierError == null) return;
    identifierError = null;
    notifyListeners();
  }

  Future<bool> appoint(String identifier) async {
    final id = identifier.trim();
    identifierError = null;
    actionError = null;
    if (id.length < 3) {
      identifierError = 'Masukkan minimal 3 karakter';
      notifyListeners();
      return false;
    }
    isBusy = true;
    notifyListeners();
    try {
      final m = await repository.appointModerator(communityId, id);
      moderators = [...moderators, m];
      return true;
    } on RepositoryException catch (e) {
      identifierError = e.message;
      return false;
    } catch (_) {
      actionError = 'Gagal menunjuk moderator. Coba lagi.';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> revoke(Moderator m) async {
    actionError = null;
    if (m.isCreator) {
      actionError = 'Pembuat komunitas tidak dapat dicabut';
      notifyListeners();
      return false;
    }
    isBusy = true;
    notifyListeners();
    try {
      await repository.revokeModerator(communityId, m.id);
      moderators = moderators.where((x) => x.id != m.id).toList();
      return true;
    } on RepositoryException catch (e) {
      actionError = e.message;
      return false;
    } catch (_) {
      actionError = 'Gagal mencabut moderator. Coba lagi.';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
