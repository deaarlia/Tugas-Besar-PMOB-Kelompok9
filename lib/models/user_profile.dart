/// Data pengguna yang sedang login (dikirim ke form buat utas).
class UserProfile {
  final String name;
  final String faculty; // contoh: FTI
  final String batch; // contoh: 24 (angkatan)

  const UserProfile({
    required this.name,
    required this.faculty,
    required this.batch,
  });

  /// Pengguna demo (sementara, sampai login terhubung).
  static const UserProfile demo = UserProfile(
    name: 'Delvara Renjana',
    faculty: 'FTI',
    batch: '24',
  );

  String get badge => "$faculty '$batch";

  /// Contoh: "FTI | 24"
  String get campusLabel => '$faculty | $batch';

  String get initials => initialsOf(name);

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
