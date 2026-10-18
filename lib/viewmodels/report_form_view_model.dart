// Paket Flutter untuk ChangeNotifier (state management)
import 'package:flutter/foundation.dart';

// Model data laporan
import '../models/report.dart';
// Model alasan laporan
import '../models/report_reason.dart';
// Model target konten yang dilaporkan
import '../models/report_target.dart';
// Repository untuk menyimpan laporan ke server/storage
import '../repositories/report_repository.dart';

// =============================================================================
// STATE (FR-04): Provider yang mengelola state dan validasi form laporan.
//
// STATE yang dikelola:
//   - Alasan laporan yang dipilih pengguna
//   - Teks keterangan tambahan
//   - Pesan error untuk masing-masing field
//   - Status loading saat laporan sedang dikirim
//
// Satu instance dibuat per pembukaan form (lihat ReportFormScreen), sehingga
// form yang dibuka lagi selalu mulai dari kondisi kosong.
// =============================================================================
class ReportFormViewModel extends ChangeNotifier { 
  ReportFormViewModel({
    required this._repository, // Repository untuk submit laporan
    required this.target,                 // Target konten yang akan dilaporkan
  });

  // Batas maksimal dankarakter untuk field keterangan (VALIDATION rule 2)
  static const int maxDescriptionLength = 300;
  static const int minDescriptiionLength = 1;
  // Repository yang digunakan untuk menyimpan laporan
  final ReportRepository _repository;

  /// Data yang diterima dari layar sebelumnya.
  final ReportTarget target;

  // --- STATE internal form ---

  // Alasan laporan yang dipilih pengguna (null = belum dipilih)
  ReportReason? _reason;

  // Teks keterangan tambahan yang diketik pengguna
  String _description = '';

  // Pesan error untuk field alasan (null = tidak ada error)
  String? _reasonError;

  // Pesan error untuk field keterangan (null = tidak ada error)
  String? _descriptionError;

  // Pesan error tingkat form, bukan per-field (contoh: laporan ganda)
  String? _formError;

  // Flag true saat laporan sedang dikirim ke server (tombol loading)
  bool _isSubmitting = false;

  // --- GETTER publik (STATE yang dibaca oleh UI) ---

  // Alasan yang sedang dipilih
  ReportReason? get reason => _reason;

  // Isi teks keterangan saat ini
  String get description => _description;

  // Pesan error field alasan (null jika tidak ada error)
  String? get reasonError => _reasonError;

  // Pesan error field keterangan (null jika tidak ada error)
  String? get descriptionError => _descriptionError;

  /// Error yang tidak terkait satu field, misalnya laporan ganda / gagal kirim.
  String? get formError => _formError;

  // True saat laporan sedang dikirim (STATE: tombol Kirim berstatus loading)
  bool get isSubmitting => _isSubmitting;

  /// Keterangan wajib hanya jika alasan "Lainnya".
  /// VALIDATION rule 2: jika alasan adalah "Lainnya", keterangan wajib diisi.
  bool get isDescriptionRequired => _reason == ReportReason.lainnya;

  // ---------------------------------------------------------------------------
  // INPUT / EVENT: Pengguna memilih salah satu alasan pelaporan.
  // State alasan diperbarui dan semua error direset.
  // ---------------------------------------------------------------------------
  void selectReason(ReportReason reason) {
    if (_isSubmitting) return; // Abaikan input saat sedang mengirim
    _reason = reason;
    _reasonError = null;      // Reset error alasan
    _descriptionError = null; // Reset error keterangan
    _formError = null;        // Reset error form
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // INPUT / EVENT: Pengguna mengetik keterangan tambahan.
  // State keterangan diperbarui dan error keterangan direset.
  // ---------------------------------------------------------------------------
  void setDescription(String value) {
    _description = value;
    _descriptionError = null; // Reset error keterangan saat user mengetik
    _formError = null;        // Reset error form
    // Selalu beri tahu pendengar supaya penghitung karakter (n/300) ikut
    // berubah saat mengetik, bukan hanya ketika ada error yang dihapus.
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // VALIDATION (FR-04): Validasi semua field sebelum laporan dikirim.
  //
  // Aturan validasi sesuai tabel workflow:
  //   (1) Alasan wajib dipilih
  //   (2) Keterangan wajib diisi jika alasan "Lainnya", maksimal 300 karakter
  //   (3) Konten yang sama tidak boleh dilaporkan dua kali oleh pengguna
  //       yang sama (validasi ini dilakukan di repository, bukan di sini)
  //
  // Return: true jika semua validasi lolos, false jika ada error.
  // FEEDBACK: Jika gagal, pesan error muncul di bawah field yang salah.
  // ---------------------------------------------------------------------------
  bool validate() {
    // VALIDATION (1): Alasan wajib dipilih
    _reasonError = _reason == null ? 'Pilih salah satu alasan laporan' : null;

    // VALIDATION (2): Keterangan wajib diisi jika alasan "Lainnya"
    //                 dan maksimal 300 karakter
    if (_reason == ReportReason.lainnya && _description.trim().isEmpty) {
      _descriptionError = 'Keterangan wajib diisi jika alasan "Lainnya"';
    } else if (_description.length > maxDescriptionLength) {
      _descriptionError =
          'Keterangan maksimal $maxDescriptionLength karakter';
    } else {
      _descriptionError = null; // Validasi lolos
    }

    // Return true hanya jika tidak ada error pada kedua field
    return _reasonError == null && _descriptionError == null;
  }

  // ---------------------------------------------------------------------------
  // INPUT / EVENT: Pengguna menekan tombol "Kirim Laporan".
  //
  // STATE: Tombol berubah menjadi loading (isSubmitting = true).
  // VALIDATION: Validasi dijalankan sebelum mengirim.
  // FEEDBACK:
  //   - Gagal validasi: pesan error di bawah field yang salah.
  //   - Gagal kirim: pesan error di banner formError.
  //   - Berhasil: mengembalikan objek Report dengan status "Menunggu".
  // NAVIGATION / RESULT: Report dikembalikan ke layar sebelumnya.
  //
  // Mengembalikan [Report] jika berhasil, atau null jika gagal/ditolak.
  // Pesan kegagalan tersedia lewat [reasonError], [descriptionError],
  // atau [formError].
  // ---------------------------------------------------------------------------
  Future<Report?> submit() async {
    if (_isSubmitting) return null; // Cegah pengiriman ganda

    _formError = null; // Reset error form sebelum submit

    // Jalankan validasi; jika gagal, tampilkan error dan batalkan
    if (!validate()) {
      notifyListeners();
      return null;
    }

    // STATE: Set flag loading agar tombol Kirim tampil sebagai loading
    _isSubmitting = true;
    notifyListeners();

    try {
      // Kirim laporan ke repository (server/in-memory)
      return await _repository.submitReport(
        target: target,
        reason: _reason!,
        description: _description,
      );
    } on DuplicateReportException catch (e) {
      // VALIDATION (3): Konten yang sama sudah pernah dilaporkan oleh pengguna
      // FEEDBACK: Tampilkan pesan error dari exception sebagai formError
      _formError = e.message;
      return null;
    } catch (_) {
      // FEEDBACK: Error umum (koneksi gagal, server error, dll)
      _formError = 'Laporan gagal dikirim. Periksa koneksi lalu coba lagi.';
      return null;
    } finally {
      // STATE: Reset flag loading setelah selesai (berhasil atau gagal)
      _isSubmitting = false;
      notifyListeners();
    }
  }
}