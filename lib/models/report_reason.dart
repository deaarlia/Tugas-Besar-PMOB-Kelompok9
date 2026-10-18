// =============================================================================
// INPUT / EVENT (FR-04): Daftar alasan pelaporan yang dapat dipilih pengguna.
// Urutan mengikuti desain Figma; "Lainnya" ditaruh terakhir.
//
// VALIDATION: Jika alasan yang dipilih adalah "Lainnya", maka field
// keterangan menjadi WAJIB diisi (lihat ReportFormViewModel.isDescriptionRequired).
// =============================================================================
enum ReportReason {
  // Konten tidak pantas / asusila
  kodeEtik(
    'Pelanggaran Kode Etik Kampus / Asusila',
    'Konten tidak pantas, pornografi, atau melanggar norma tata susila kampus.',
  ),
  // Ujaran kebencian berdasarkan ras, agama, atau golongan
  sara(
    'Ujaran Kebencian & SARA',
    'Diskriminasi, fitnah rasial, penistaan agama, antargolongan, atau gender.',
  ),
  // Spam atau penipuan berkedok promosi
  spam(
    'Pesan Spam / Penipuan',
    'Promosi komersial ilegal, phishing akun kampus, tautan mencurigakan, '
        'atau spam berulang.',
  ),
  // Pelecehan atau perundungan secara siber
  pelecehan(
    'Pelecehan / Perundungan (Cyberbullying)',
    'Ancaman, intimidasi, serangan verbal personal, doxing, atau '
        'perundungan siber.',
  ),
  // Informasi palsu/hoaks seputar kegiatan akademik
  hoaks(
    'Informasi Palsu / Hoaks Seputar Akademik',
    'Penyebaran informasi keliru terkait jadwal KRS, UKT, pengumuman '
        'rektorat, atau beasiswa.',
  ),
  // Pelanggaran hak cipta atau plagiasi karya ilmiah
  hakCipta(
    'Pelanggaran Hak Cipta / Plagiasi',
    'Penggunaan karya ilmiah, berkas tugas, atau materi berhak cipta '
        'tanpa izin sah.',
  ),
  // Alasan di luar kategori di atas — VALIDATION: keterangan wajib diisi
  lainnya(
    'Lainnya',
    'Alasan lain di luar kategori di atas. Keterangan wajib diisi.',
  );

  // Konstruktor enum menerima label tampilan dan deskripsi penjelasan
  const ReportReason(this.label, this.description);

  // Label singkat yang tampil di setiap kartu pilihan alasan
  final String label;

  // Deskripsi detail yang tampil di bawah label pada kartu pilihan
  final String description;

  // Nilai yang dikirim ke server/API
  String get apiValue => name;
}