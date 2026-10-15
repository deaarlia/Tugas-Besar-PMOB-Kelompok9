import 'dart:typed_data';

import '../models/attachments.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';

/// Exception khusus untuk kegagalan membuat/mengambil utas.
class ThreadException implements Exception {
  final String message;
  const ThreadException(this.message);

  @override
  String toString() => message;
}

/// Data layer (simulasi, belum memakai backend).
/// Singleton agar Home dan Form memakai sumber data yang sama.
class ThreadRepository {
  ThreadRepository._();
  static final ThreadRepository instance = ThreadRepository._();

  /// true -> createThread selalu gagal (untuk demo error state).
  bool simulateError = false;

  static DateTime _ago(Duration d) => DateTime.now().subtract(d);

  final List<ThreadPost> _threads = [
    ThreadPost(
      id: 'T001',
      title: 'Adakah Rekomendasi Dosen Pembimbing untuk Skripsi Machine Learning di Teknik Komputer?',
      content: 'Halo teman-teman semua! Saya berencana mengambil topik Machine Learning untuk deteksi penyakit daun kelapa sawit di Sumbar. Kira-kira dosen pembimbing laboratorium mana yang cocok?',
      authorName: 'Rafi Kurniawan',
      authorBadge: "FTI '22",
      isAnonymous: false,
      upvotes: 42,
      comments: 18,
      createdAt: _ago(const Duration(minutes: 15)),
    ),
    ThreadPost(
      id: 'T002',
      title: 'Kondisi Parkiran Gedung Kuliah A Jam 08.00 Pagi Ini Sangat Penuh',
      content: 'Teman-teman yang ada kuliah jam 08.40 di GKB sebaiknya parkir di depan gedung PKM atau dekat rektorat. Lahan parkir motor GKB sudah meluber sampai ke badan jalan akses atas.',
      authorName: 'Anonim',
      authorBadge: '',
      isAnonymous: true,
      placeholderPhotoCount: 3,
      upvotes: 89,
      comments: 34,
      createdAt: _ago(const Duration(hours: 1)),
    ),
    ThreadPost(
      id: 'T003',
      title: 'Prosedur Pengajuan Cuti Akademik Semester Ganjil via SIA Unand',
      content: 'Bagi yang perlu menunda semester karena magang atau alasan lainnya, berikut alur permohonan surat cuti akademik lewat laman SIA.',
      authorName: 'Aisyah Putri',
      authorBadge: "FK '21",
      isAnonymous: false,
      upvotes: 120,
      comments: 45,
      createdAt: _ago(const Duration(hours: 3)),
    ),
  ];

  List<ThreadPost> get threads => List.unmodifiable(_threads);

  Future<List<ThreadPost>> fetchThreads() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.unmodifiable(_threads);
  }

  /// Mengembalikan [ThreadPost] yang baru dibuat, atau melempar [ThreadException].
  Future<ThreadPost> createThread({
    required String title,
    required String content,
    required List<String> topics,
    required List<Uint8List> photos,
    String? linkUrl,
    PollDraft? poll,
    DocumentAttachment? document,
    required UserProfile author,
    required bool isAnonymous,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi request
    if (simulateError) {
      throw const ThreadException(
        'Gagal mengirim utas. Periksa koneksi internet.',
      );
    }
    final thread = ThreadPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      topics: List.unmodifiable(topics),
      authorName: author.name,
      authorBadge: author.badge,
      isAnonymous: isAnonymous,
      photos: List.unmodifiable(photos),
      linkUrl: linkUrl,
      poll: poll,
      document: document,
      createdAt: DateTime.now(),
    );
    _threads.insert(0, thread);
    return thread;
  }
}
