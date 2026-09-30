import '../models/item.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
class ItemRepository {
  static const List<Item> _items = [
    Item(
      id: '1',
      title:
          'Bagaimana tips memilih dosen pembimbing skripsi di Fasilkom Unand agar lancar?',
      subtitle: "Fajar Ramadhan • Information Systems '24",
      description:
          'Bagi kakak-kakak tingkat yang sudah lulus atau sedang seminar, mohon pencerahannya terkait kriteria dosen pembimbing yang responsif dan bagaimana etika menghubungi beliau pertama kali.',
    ),
    Item(
      id: '2',
      title:
          'Rekomendasi tempat belajar & nugas yang tenang di sekitar Kampus Limau Manis?',
      subtitle: "Aisyah Putri • Kedokteran '22",
      description:
          'Perpustakaan pusat sering ramai saat minggu UTS. Apakah ada working space atau kafe ramah mahasiswa dengan wifi kencang dan colokan memadai di dekat gerbang Unand?',
    ),
    Item(
      id: '3',
      title:
          'Prosedur pengajuan cuti akademik semester ganjil melalui portal akademik Unand?',
      subtitle: "Rian Hidayat • Teknik Elektro '23",
      description:
          'Apakah surat pengantar dari Kaprodi harus diunggah secara online atau diserahkan fisik ke BAAK? Mohon info batas akhir pengajuannya juga, rekan-rekan.',
    ),
  ];

  /// Mengambil daftar item.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Item>> fetchItems({bool simulateError = true}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}