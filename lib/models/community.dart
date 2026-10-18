class CommunityModerator {
  final String name;
  final String role; // e.g. "Lead Moderator", "Moderator Konten"
  final String studentBatch; // e.g. "Mahasiswa SI '21"
  final String badge; // e.g. "Admin", "Mod"

  const CommunityModerator({
    required this.name,
    required this.role,
    required this.studentBatch,
    required this.badge,
  });
}

class Community {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final String? bannerUrl;
  final String categoryTag; // e.g. "HIMA", "AKADEMIK", "UKM"
  final List<String> rules;
  final int memberCount;
  final bool isFollowing;
  
  // Informasi Tambahan untuk Tab "Tentang"
  final String createdDate;
  final String location;
  final List<String> officialLinks;
  final List<CommunityModerator> moderators;

  const Community({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    this.bannerUrl,
    this.categoryTag = 'HIMA',
    this.rules = const [],
    this.memberCount = 0,
    this.isFollowing = false,
    this.createdDate = '12 September 2024',
    this.location = 'Gedung FTI Lt. 2, Kampus Unand Limau Manih, Padang',
    this.officialLinks = const ['@hmsi.unand.ac.id', '#hmsi_unand', 'fti.unand.ac.id/si'],
    this.moderators = const [
      CommunityModerator(name: 'Fathur Rahman', role: 'Lead Moderator', studentBatch: 'Mahasiswa SI \'21', badge: 'Admin'),
      CommunityModerator(name: 'M. Daffa Naufal', role: 'Moderator Konten', studentBatch: 'Mahasiswa SI \'22', badge: 'Mod'),
    ],
  });

  /// Inisial (maks. 2 huruf kapital) dari nama komunitas, dipakai untuk avatar.
  String get initials =>
      name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase();

  Community copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? bannerUrl,
    String? categoryTag,
    List<String>? rules,
    int? memberCount,
    bool? isFollowing,
    String? createdDate,
    String? location,
    List<String>? officialLinks,
    List<CommunityModerator>? moderators,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      categoryTag: categoryTag ?? this.categoryTag,
      rules: rules ?? this.rules,
      memberCount: memberCount ?? this.memberCount,
      isFollowing: isFollowing ?? this.isFollowing,
      createdDate: createdDate ?? this.createdDate,
      location: location ?? this.location,
      officialLinks: officialLinks ?? this.officialLinks,
      moderators: moderators ?? this.moderators,
    );
  }
}