// lib/providers/community_rules_provider.dart
import 'package:flutter/foundation.dart';
import 'package:unand_space/models/community.dart';
import 'package:unand_space/repositories/community_repository.dart';

class CommunityRulesProvider extends ChangeNotifier {
  CommunityRulesProvider({required this.repository, required this.community})
    : _rules = community.rules ?? '';

  final CommunityRepository repository;
  final Community community;

  String _rules;
  String? rulesError;
  String? submitError;
  bool isSubmitting = false;

  String get rules => _rules;
  bool get hasChanges => _rules.trim() != (community.rules ?? '').trim();
  bool get canSubmit => !isSubmitting && hasChanges;

  void setRules(String v) {
    _rules = v;
    rulesError = null;
    notifyListeners();
  }

  /// Mengembalikan Community yang sudah diperbarui, atau null jika gagal.
  Future<Community?> submit() async {
    submitError = null;
    final text = _rules.trim();
    if (text.isEmpty) {
      rulesError = 'Aturan komunitas tidak boleh kosong';
      notifyListeners();
      return null;
    }
    if (text.length > CommunityRules.rulesMax) {
      rulesError = 'Aturan maksimal ${CommunityRules.rulesMax} karakter';
      notifyListeners();
      return null;
    }
    isSubmitting = true;
    notifyListeners();
    try {
      return await repository.updateRules(community.id, text);
    } catch (_) {
      submitError = 'Gagal menyimpan aturan. Periksa koneksi lalu coba lagi.';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
