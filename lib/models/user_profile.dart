/// Model data profil pengguna UnandSpace.
class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.username,
    required this.bio,
    required this.faculty,
    required this.major,
    required this.year,
    required this.linkedinUrl,
    required this.location,
    required this.isActive,
    required this.followers,
    required this.following,
    this.hideYearFromPublic = false,
    this.avatarAsset,
  });

  final String fullName;
  final String username;
  final String bio;
  final String faculty;
  final String major;
  final int year;
  final String linkedinUrl;
  final String location;
  final bool isActive;
  final int followers;
  final int following;
  final bool hideYearFromPublic;

  /// Null = pakai avatar default (ikon orang).
  final String? avatarAsset;

  String get yearLabel => '$major, ${faculty.split(" ").first} $year';

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? bio,
    String? faculty,
    String? major,
    int? year,
    String? linkedinUrl,
    String? location,
    bool? isActive,
    int? followers,
    int? following,
    bool? hideYearFromPublic,
    String? avatarAsset,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      year: year ?? this.year,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      hideYearFromPublic: hideYearFromPublic ?? this.hideYearFromPublic,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }
}

/// Data demo – ganti dengan data asli dari API/auth.
const UserProfile kDemoUserProfile = UserProfile(
  fullName: 'Fajar Nugraha',
  username: 'fajarnugraha',
  bio: 'Mahasiswa tingkat akhir yang suka ngulik UI/UX & Web Dev. '
      'Jangan ragu menyapa! 🌿✨',
  faculty: 'FTI',
  major: 'Sistem Informasi',
  year: 2021,
  linkedinUrl: 'linkedin.com/in/fajarnugraha',
  location: 'Kampus Limau Manis',
  isActive: true,
  followers: 385,
  following: 142,
  hideYearFromPublic: false,
);
