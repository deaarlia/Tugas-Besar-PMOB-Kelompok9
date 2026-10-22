/// Tipe notifikasi — menentukan ikon yang ditampilkan.
enum NotifType {
  moderation,    // tim moderasi / sistem
  reply,         // balasan postingan
  like,          // suka / upvote
  announcement,  // pengumuman komunitas
  verification,  // verifikasi dokumen / beasiswa
  mention,       // disebut di postingan
  event,         // acara komunitas
}

/// Halaman tujuan saat notifikasi diklik.
enum NotifDestination {
  thread,       // halaman detail utas (ThreadDetailScreen)
  community,    // halaman detail komunitas (CommunityDetailScreen)
  myReports,    // halaman laporan saya (MyReportsScreen)
  communityExplore, // daftar komunitas
  none,         // tidak ada navigasi khusus
}

/// Satu baris notifikasi.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.actorName,
    required this.message,
    required this.preview,
    required this.timeAgo,
    this.isRead = false,
    this.isToday = true,
    this.destination = NotifDestination.none,
    this.destinationId,
  });

  final String id;
  final NotifType type;

  /// Nama pengirim / sistem yang memicu notifikasi.
  final String actorName;

  /// Teks singkat setelah nama aktor, mis. "menghapus laporan pelanggaran".
  final String message;

  /// Cuplikan konten / preview, mis. kutipan komentar.
  final String preview;

  /// Teks waktu, mis. "Baru saja", "15 mnt lalu", "2 jam lalu".
  final String timeAgo;

  final bool isRead;

  /// true = tampil di seksi "HARI INI", false = "SEBELUMNYA"
  final bool isToday;

  /// Jenis halaman tujuan navigasi.
  final NotifDestination destination;

  /// ID entitas tujuan (thread id, community id, dll.).
  final String? destinationId;

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        type: type,
        actorName: actorName,
        message: message,
        preview: preview,
        timeAgo: timeAgo,
        isRead: isRead ?? this.isRead,
        isToday: isToday,
        destination: destination,
        destinationId: destinationId,
      );
}
