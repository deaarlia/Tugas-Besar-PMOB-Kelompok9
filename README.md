# tugas_pmob

A new Flutter project.

## Arsitektur aplikasi

Source aplikasi dikelompokkan berdasarkan tanggung jawab:

- `lib/screens/` dan `lib/widgets/` berisi View yang merender UI, mengelola
  navigasi, serta menampilkan pesan kepada pengguna.
- `lib/viewmodels/` berisi state dan aksi layar, termasuk pemuatan feed,
  pembuatan utas, pengelolaan lampiran, dan validasi topik.
- `lib/repositories/` berisi repository sebagai sumber data yang digunakan
  ViewModel dan layar.
- `lib/models/` berisi model data aplikasi.

ViewModel menggunakan `ChangeNotifier`; View berlangganan menggunakan
`ListenableBuilder` bawaan Flutter. Dependency `provider` digunakan untuk
menyediakan repository serta state form komunitas pada widget tree.

## Modul komunitas

Modul komunitas mendukung feed berpaginasi, pencarian utas dengan rekomendasi
keyword, edit dan soft delete utas, komentar dan balasan hingga lima tingkat,
voting, pengurutan komentar, serta penandaan jawaban terbaik. Utas baru masuk ke
komunitas `Umum`. Lampiran kamera/galeri maksimal tiga foto dan pilihan unggah
anonim tersedia di form utas. Balasan dapat memuat maksimal 500 karakter,
hingga tiga foto dan satu file dokumen dari layar composer yang diperbesar.

Implementasi repository saat ini menyimpan perubahan di memori untuk demo;
data akan kembali ke seed saat aplikasi dimulai ulang dan belum tersambung ke
backend.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
