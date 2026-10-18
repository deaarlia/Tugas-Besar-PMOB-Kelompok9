// Paket Flutter untuk ChangeNotifier (state management)
import 'package:flutter/foundation.dart';

// Model laporan
import '../models/report.dart';
// Repository untuk mengambil daftar laporan
import '../repositories/report_repository.dart';

// =============================================================================
// NAVIGATION / RESULT (FR-04): Provider untuk layar "Laporan Saya".
// Mengelola state loading, error, dan daftar laporan milik pengguna.
//
// Layar ini adalah hasil akhir workflow: pengguna dapat melihat laporan baru
// yang baru saja dikirim dengan status "Menunggu".
// =============================================================================
class MyReportsViewModel extends ChangeNotifier {
  MyReportsViewModel(this._repository);

  // Repository yang digunakan untuk mengambil data laporan
  final ReportRepository _repository;

  // --- STATE internal ---

  // Daftar laporan milik pengguna (kosong = belum ada laporan)
  List<Report> _reports = const <Report>[];

  // True saat data sedang dimuat dari repository
  bool _isLoading = false;

  // Pesan error jika gagal memuat laporan (null = tidak ada error)
  String? _error;

  // --- GETTER publik (STATE yang dibaca oleh UI) ---

  // Daftar laporan yang ditampilkan di layar "Laporan Saya"
  List<Report> get reports => _reports;

  // True saat sedang memuat (tampilkan spinner)
  bool get isLoading => _isLoading;

  // Pesan error (null jika berhasil)
  String? get error => _error;

  // --- STATE filter status (dipindah dari layar ke ViewModel) ---

  // Status yang sedang dipilih di tab filter (null = tab "Semua")
  ReportStatus? _selectedStatus;

  ReportStatus? get selectedStatus => _selectedStatus;

  // Daftar laporan setelah filter status diterapkan
  List<Report> get filteredReports => _selectedStatus == null
      ? _reports
      : _reports.where((Report r) => r.status == _selectedStatus).toList();

  // Jumlah laporan untuk satu status (badge pada tab)
  int countOf(ReportStatus status) =>
      _reports.where((Report r) => r.status == status).length;

  // Dipanggil saat pengguna menekan tab filter
  void selectStatus(ReportStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  // Dipanggil saat layar dibuka agar filter selalu mulai dari "Semua"
  // (tanpa notifyListeners; load() sesudahnya yang memicu rebuild)
  void resetFilter() => _selectedStatus = null;

  // ---------------------------------------------------------------------------
  // NAVIGATION / RESULT: Memuat daftar laporan dari repository.
  // Dipanggil saat layar "Laporan Saya" pertama kali ditampilkan.
  //
  // STATE yang berubah selama proses:
  //   1. isLoading = true  → tampilkan spinner
  //   2. Data berhasil dimuat → tampilkan daftar laporan
  //   3. Gagal dimuat → tampilkan pesan error dengan tombol "Coba lagi"
  // ---------------------------------------------------------------------------
  Future<void> load() async {
    // STATE: Mulai loading
    _isLoading = true;
    _error = null;   // Reset error sebelumnya
    notifyListeners();

    try {
      // Ambil daftar laporan dari repository (server/in-memory)
      _reports = await _repository.getMyReports();
    } catch (_) {
      // FEEDBACK: Gagal memuat — tampilkan pesan error di layar
      _error = 'Gagal memuat laporan. Periksa koneksi lalu coba lagi.';
    } finally {
      // STATE: Selesai loading (berhasil atau gagal)
      _isLoading = false;
      notifyListeners();
    }
  }
}
