enum CommunityCategory {
  hima('HIMA / Jurusan'),
  bem('BEM / Fakultas'),
  ukm('UKM Unand'),
  studyGroup('Kelompok Belajar / Riset'),
  hobby('Minat & Hobi');

  const CommunityCategory(this.label);
  final String label;
}

abstract final class CommunityRules {
  static const nameMin = 3;
  static const nameMax = 50;
  static const descriptionMax = 200;
  static const rulesMax = 500;
  static const coverMaxBytes = 5 * 1024 * 1024;
}

enum CommunityRole { guest, moderator, creator }

class Community {
  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.isPublic = true,
    this.iconUrl,
    this.coverUrl,
    this.rules,
    this.createdAt,
    this.creatorName,
    this.memberCount = 0,
    this.myRole = CommunityRole.guest,
  });

  final String id;
  final String name;
  final String description;
  final CommunityCategory category;
  final bool isPublic;
  final String? iconUrl;
  final String? coverUrl;
  final String? rules;
  final DateTime? createdAt;
  final String? creatorName;
  final int memberCount;
  final CommunityRole myRole;
}

class CommunityDraft {
  const CommunityDraft({
    required this.name,
    required this.description,
    required this.category,
    required this.isPublic,
    this.rules,
    this.iconPath,
    this.coverPath,
  });

  final String name;
  final String description;
  final CommunityCategory category;
  final bool isPublic;
  final String? rules;
  final String? iconPath;
  final String? coverPath;
}

class CommunityFormResult {
  const CommunityFormResult.saved(Community this.community) : deleted = false;
  const CommunityFormResult.deleted() : community = null, deleted = true;

  final Community? community;
  final bool deleted;
}

class Moderator {
  const Moderator({
    required this.id,
    required this.name,
    this.isCreator = false,
  });

  final String id;
  final String name;
  final bool isCreator; // pembuat otomatis moderator dan tidak bisa dicabut
}
