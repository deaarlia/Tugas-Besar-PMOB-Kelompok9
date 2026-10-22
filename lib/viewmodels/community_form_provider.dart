import 'package:flutter/foundation.dart';
import 'package:unand_space/models/community.dart';
import 'package:unand_space/repositories/community_repository.dart';

class CommunityFormProvider extends ChangeNotifier {
  CommunityFormProvider({required this.repository, this.initial}) {
    final c = initial;
    if (c != null) {
      _name = c.name;
      _description = c.description;
      _category = c.category;
      _isPublic = c.isPublic;
      _rules = c.rules ?? '';
    }
  }

  final CommunityRepository repository;
  final Community? initial;

  String _name = '';
  String _description = '';
  String _rules = '';
  CommunityCategory? _category;
  bool _isPublic = true;
  String? _iconPath;
  String? _coverPath;

  String? nameError;
  String? descriptionError;
  String? categoryError;
  String? submitError;
  bool isSubmitting = false;
  bool isDeleting = false;

  bool get isEdit => initial != null;
  bool get isBusy => isSubmitting || isDeleting;
  String get name => _name;
  String get description => _description;
  String get rules => _rules;
  CommunityCategory? get category => _category;
  bool get isPublic => _isPublic;
  String? get iconPath => _iconPath;
  String? get coverPath => _coverPath;

  bool get hasChanges {
    final c = initial;
    if (c == null) return true;
    return _name.trim() != c.name ||
        _description.trim() != c.description ||
        _category != c.category ||
        _isPublic != c.isPublic ||
        _iconPath != null ||
        _coverPath != null;
  }

  bool get canSubmit => !isBusy && hasChanges;

  void setName(String v) {
    _name = v;
    nameError = null;
    notifyListeners();
  }

  void setDescription(String v) {
    _description = v;
    descriptionError = null;
    notifyListeners();
  }

  void setRules(String v) {
    _rules = v;
    notifyListeners();
  }

  void setCategory(CommunityCategory v) {
    _category = v;
    categoryError = null;
    notifyListeners();
  }

  void setPublic(bool v) {
    _isPublic = v;
    notifyListeners();
  }

  void setIconPath(String v) {
    _iconPath = v;
    notifyListeners();
  }

  void setCoverPath(String v) {
    _coverPath = v;
    notifyListeners();
  }

  bool _validate() {
    final n = _name.trim();
    nameError = n.length < CommunityRules.nameMin
        ? 'Nama komunitas minimal ${CommunityRules.nameMin} karakter'
        : null;
    descriptionError = _description.trim().isEmpty
        ? 'Deskripsi wajib diisi'
        : null;
    categoryError = _category == null ? 'Pilih satu kategori organisasi' : null;
    notifyListeners();
    return nameError == null &&
        descriptionError == null &&
        categoryError == null;
  }

  Future<Community?> submit() async {
    submitError = null;
    if (!_validate()) return null;
    isSubmitting = true;
    notifyListeners();
    try {
      final taken = await repository.isNameTaken(
        _name.trim(),
        excludeId: initial?.id,
      );
      if (taken) {
        nameError = 'Nama komunitas sudah dipakai';
        return null;
      }
      final draft = CommunityDraft(
        name: _name.trim(),
        description: _description.trim(),
        category: _category!,
        isPublic: _isPublic,
        rules: _rules.trim().isEmpty ? null : _rules.trim(),
        iconPath: _iconPath,
        coverPath: _coverPath,
      );
      return isEdit
          ? await repository.update(initial!.id, draft)
          : await repository.create(draft);
    } catch (_) {
      submitError = 'Gagal menyimpan. Periksa koneksi lalu coba lagi.';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> delete() async {
    submitError = null;
    isDeleting = true;
    notifyListeners();
    try {
      await repository.delete(initial!.id);
      return true;
    } catch (_) {
      submitError = 'Gagal menghapus komunitas. Coba lagi.';
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
