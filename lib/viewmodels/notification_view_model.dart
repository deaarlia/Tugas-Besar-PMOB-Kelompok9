import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';

/// ViewModel untuk halaman Notifikasi.
/// Menyediakan data dummy dan aksi "tandai semua dibaca".
class NotificationViewModel extends ChangeNotifier {
  List<NotificationItem> _items = _initialItems;

  List<NotificationItem> get items => _items;

  List<NotificationItem> get todayItems =>
      _items.where((n) => n.isToday).toList();

  List<NotificationItem> get previousItems =>
      _items.where((n) => !n.isToday).toList();

  int get unreadCount => _items.where((n) => !n.isRead).length;

  bool get allRead => unreadCount == 0;

  /// Tandai satu notifikasi sebagai sudah dibaca.
  void markAsRead(String id) {
    _items = _items
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    notifyListeners();
  }

  /// Tandai semua notifikasi sebagai sudah dibaca.
  void markAllAsRead() {
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  /// Kembalikan item berdasarkan id (untuk keperluan navigasi).
  NotificationItem? getById(String id) {
    try {
      return _items.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Data dummy — ganti dengan REST API di Modul 3
  // ─────────────────────────────────────────────────────────────────────
  static final List<NotificationItem> _initialItems = [
    // ── HARI INI ──────────────────────────────────────────────────────
    const NotificationItem(
      id: 'n1',
      type: NotifType.moderation,
      actorName: 'Tim Moderasi',
      message: 'menghapus laporan pelanggaran #REP-8941',
      preview:
          'Terima kasih telah menjaga keamanan ruang diskusi akademik Anda...',
      timeAgo: 'Baru saja',
      isRead: false,
      isToday: true,
      destination: NotifDestination.myReports,
    ),
    const NotificationItem(
      id: 'n2',
      type: NotifType.reply,
      actorName: 'Aisyah Putri',
      message: 'membalas postingan Anda',
      preview: '"Terima kasih banyak kak, sangat membantu alur ...',
      timeAgo: '15 mnt lalu',
      isRead: false,
      isToday: true,
      destination: NotifDestination.thread,
      destinationId: 'thread-2',
    ),
    const NotificationItem(
      id: 'n3',
      type: NotifType.like,
      actorName: '15 mahasiswa',
      message: 'menyukai rangkuman kuliah Anda',
      preview: 'Utas di Forum FTI sedang tren di Limau Manih.',
      timeAgo: '45 mnt lalu',
      isRead: false,
      isToday: true,
      destination: NotifDestination.thread,
      destinationId: 'thread-1',
    ),
    const NotificationItem(
      id: 'n4',
      type: NotifType.announcement,
      actorName: 'HIMA SI UNAND',
      message: 'merilis pengumuman baru',
      preview: 'Open Recruitment Panitia Seminar Nasional IT...',
      timeAgo: '2 jam lalu',
      isRead: false,
      isToday: true,
      destination: NotifDestination.community,
      destinationId: 'comm-2',
    ),

    // ── SEBELUMNYA ────────────────────────────────────────────────────
    const NotificationItem(
      id: 'n5',
      type: NotifType.verification,
      actorName: 'DITMAWA UNAND',
      message: 'mengunggah verifikasi beasiswa',
      preview: 'Lampiran berkas semester ganjil sudah tersedia di ...',
      timeAgo: 'Kemarin',
      isRead: true,
      isToday: false,
      destination: NotifDestination.myReports,
    ),
    const NotificationItem(
      id: 'n6',
      type: NotifType.mention,
      actorName: 'Fajar Pratama',
      message: 'menandai Anda di Struktur Data',
      preview: '"Modul praktikum bab 4 sudah diunggah di...',
      timeAgo: '3 hari lalu',
      isRead: true,
      isToday: false,
      destination: NotifDestination.thread,
      destinationId: 'thread-7',
    ),
    const NotificationItem(
      id: 'n7',
      type: NotifType.event,
      actorName: 'Komunitas Robotika Unand',
      message: 'mengadakan Workshop',
      preview: 'Microcontroller ESP32 & IoT di Lab Terpadu...',
      timeAgo: '5 hari lalu',
      isRead: true,
      isToday: false,
      destination: NotifDestination.community,
      destinationId: 'comm-3',
    ),
  ];
}
