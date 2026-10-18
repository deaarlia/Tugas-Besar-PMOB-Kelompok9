// Model laporan dan status laporan
import '../models/report.dart';
// Model alasan laporan
import '../models/report_reason.dart';
// Model target laporan (konten yang dilaporkan)
import '../models/report_target.dart';

// =============================================================================
// VALIDATION (3): Exception yang dilempar ketika pengguna mencoba melaporkan
// konten yang sama untuk kedua kalinya.
// Sesuai aturan: "Konten yang sama tidak boleh dilaporkan dua kali oleh
// pengguna yang sama."
// =============================================================================
class DuplicateReportException implements Exception {
  const DuplicateReportException([
    // Pesan default yang ditampilkan kepada pengguna
    this.message = 'Kamu sudah melaporkan konten ini sebelumnya.',
  ]);

  // Pesan error yang ditampilkan di form (formError)
  final String message;

  // Representasi string untuk debugging
  @override
  String toString() => 'DuplicateReportException: $message';
}

// =============================================================================
// Kontrak/antarmuka penyimpanan laporan (abstraksi layer data).
//
// Sekarang diimplementasikan in-memory (InMemoryReportRepository).
// Nanti cukup membuat implementasi baru yang memanggil REST API (NFR-01),
// tanpa mengubah provider dan layar.
// =============================================================================
abstract class ReportRepository {
  /// Menyimpan laporan baru dengan status "Menunggu".
  ///
  /// Melempar [DuplicateReportException] jika konten yang sama sudah
  /// dilaporkan oleh pengguna yang sama.
  Future<Report> submitReport({
    required ReportTarget target,     // Konten yang dilaporkan
    required ReportReason reason,     // Alasan laporan
    String? description,              // Keterangan tambahan (opsional)
  });

  /// Laporan milik pengguna saat ini, yang terbaru di atas.
  Future<List<Report>> getMyReports();
}

// =============================================================================
// Implementasi in-memory dari ReportRepository.
// Digunakan untuk demo dan pengujian tanpa koneksi server.
// =============================================================================
class InMemoryReportRepository implements ReportRepository {
  InMemoryReportRepository({
    this.currentUserId = 'user-demo', // ID pengguna demo
    this.latency = const Duration(milliseconds: 900), // Jeda buatan untuk demo
    this.seedDemoData = true, // Apakah diisi data contoh untuk demo
  });

  /// Pengguna login sementara (belum ada modul autentikasi).
  final String currentUserId;

  /// Jeda buatan supaya state loading pada tombol Kirim terlihat saat demo.
  final Duration latency;

  /// Isi satu laporan contoh (status Diproses) agar filter bisa didemokan.
  /// Isi false pada pengujian otomatis agar daftar mulai kosong.
  final bool seedDemoData;

  // Daftar laporan yang disimpan di memori (tidak persisten)
  late final List<Report> _reports = <Report>[
    if (seedDemoData)
      // Laporan contoh dengan status "Diproses" untuk keperluan demo filter
      Report(
        id: '#REP-2026-UNAND-8900',
        reporterId: currentUserId,
        targetType: ReportTargetType.thread,
        targetId: 'seed-thread-1',
        targetExcerpt: 'Jasa joki skripsi fast track garansi lolos sidang '
            'gelombang 1 WA admin 0812...',
        targetAuthorName: 'Akun Anonim',
        targetCommunityName: 'Informatika FTI',
        reason: ReportReason.spam,
        status: ReportStatus.diproses,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
  ];

  // Counter untuk membuat ID laporan yang unik secara berurutan
  int _counter = 0;

  // ---------------------------------------------------------------------------
  // STATE + VALIDATION: Menyimpan laporan baru.
  //
  // Alur:
  //   1. Tunda sebentar (simulasi jaringan) agar animasi loading terlihat
  //   2. Cek apakah konten sudah pernah dilaporkan (VALIDATION 3)
  //   3. Buat objek Report baru dengan status "Menunggu" (STATE)
  //   4. Simpan ke daftar in-memory
  // ---------------------------------------------------------------------------
  @override
  Future<Report> submitReport({
    required ReportTarget target,
    required ReportReason reason,
    String? description,
  }) async {
    // Simulasi latency jaringan agar animasi loading terlihat di demo
    await Future<void>.delayed(latency);

    // VALIDATION (3): Cek laporan ganda — pengguna yang sama, konten yang sama
    final bool alreadyReported = _reports.any(
      (Report r) =>
          r.reporterId == currentUserId &&
          r.targetType == target.type &&
          r.targetId == target.id,
    );
    if (alreadyReported) {
      // Lempar exception; akan ditangkap oleh ReportFormViewModel.submit()
      throw const DuplicateReportException();
    }

    // Bersihkan spasi berlebih pada keterangan
    final String trimmed = (description ?? '').trim();
    _counter++;
    final DateTime now = DateTime.now();

    // Buat objek Report baru; status selalu "Menunggu" untuk laporan baru
    final Report report = Report(
      id: '#REP-${now.year}-UNAND-${8940 + _counter}', // ID unik berurutan
      reporterId: currentUserId,
      targetType: target.type,
      targetId: target.id,
      targetExcerpt: target.excerpt,
      targetAuthorName: target.authorName,
      targetCommunityName: target.communityName,
      reason: reason,
      description: trimmed.isEmpty ? null : trimmed, // Kosong disimpan sebagai null
      status: ReportStatus.menunggu, // STATE awal selalu "Menunggu"
      createdAt: now,
    );

    // Simpan di awal daftar agar laporan terbaru muncul di atas
    _reports.insert(0, report);
    return report;
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION / RESULT: Mengambil semua laporan milik pengguna saat ini.
  // Ditampilkan di layar "Laporan Saya" sebagai hasil akhir workflow.
  // ---------------------------------------------------------------------------
  @override
  Future<List<Report>> getMyReports() async {
    // Simulasi latency jaringan (lebih cepat dari submit)
    await Future<void>.delayed(latency ~/ 3);
    // Kembalikan daftar yang tidak dapat dimodifikasi dari luar
    return List<Report>.unmodifiable(
      _reports.where((Report r) => r.reporterId == currentUserId),
    );
  }
}