// =============================================================================
// INPUT / EVENT (FR-04): Tipe konten yang dapat dilaporkan oleh pengguna.
// Pengguna menekan tombol "Laporkan" pada utas atau komentar.
// =============================================================================
enum ReportTargetType {
  // Utas (postingan utama di forum komunitas)
  thread('Utas'),
  // Komentar (balasan di bawah utas)
  comment('Komentar');

  // Konstruktor enum menyimpan label yang ditampilkan di UI
  const ReportTargetType(this.label);

  // Label yang ditampilkan kepada pengguna (contoh: "Utas", "Komentar")
  final String label;

  // Nilai yang dikirim ke server/API (menggunakan nama enum sebagai string)
  String get apiValue => name;
} // ← penutup enum ReportTargetType

// =============================================================================
// INPUT / EVENT (FR-04): Data target yang DIKIRIM dari layar utas/komentar
// ke layar form laporan saat pengguna menekan tombol "Laporkan".
//
// Hanya berisi apa yang dibutuhkan form: identitas konten (untuk laporan)
// dan ringkasan konten (untuk pratinjau di form).
// =============================================================================
class ReportTarget {
  const ReportTarget({
    required this.type,       // Tipe konten: thread atau comment
    required this.id,         // ID unik konten yang dilaporkan
    required this.authorName, // Nama penulis konten
    required this.excerpt,    // Cuplikan teks konten (untuk pratinjau di form)
    this.communityName,       // Nama komunitas (opsional)
  });

  // Tipe konten yang dilaporkan (utas atau komentar)
  final ReportTargetType type;

  // ID unik konten di database
  final String id;

  // Nama penulis konten yang dilaporkan
  final String authorName;

  /// Judul utas, atau potongan isi komentar.
  /// Ditampilkan sebagai pratinjau di form laporan agar pengguna yakin
  /// melaporkan konten yang benar.
  final String excerpt;

  /// Boleh kosong: desain detail utas tidak menampilkan nama komunitas.
  final String? communityName;

  // Representasi string untuk debug/logging
  @override
  String toString() =>
      'ReportTarget(type: ${type.apiValue}, id: $id, author: $authorName)';
}