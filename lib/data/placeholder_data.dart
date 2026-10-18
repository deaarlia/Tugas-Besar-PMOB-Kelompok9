import '../models/report_target.dart';

// PLACEHOLDER: isi diambil dari desain Figma supaya Beranda dan workflow
// laporan bisa didemokan. Hapus file ini saat utas sudah diambil dari
// REST API (pindahkan kelas DemoPost ke models/ lebih dulu).

class DemoPost {
  const DemoPost({
    required this.id,
    required this.author,
    required this.tag,
    required this.sub,
    required this.time,
    required this.title,
    required this.body,
    required this.votes,
    required this.comments,
    this.follow = true,
    this.communityId = 'comm-1',
    this.minutesAgo = 0,
  });

  final String id, author, tag, sub, time, title, body;
  final int votes, comments;
  final bool follow;

  /// ID komunitas tempat utas diposting (untuk filter FR-03).
  final String communityId;

  /// Umur utas dalam menit, dipakai untuk urutan "Terbaru".
  final int minutesAgo;

  /// Data yang dikirim ke form laporan saat utas ini dilaporkan.
  ReportTarget toReportTarget() => ReportTarget(
        type: ReportTargetType.thread,
        id: id,
        authorName: author,
        excerpt: title,
        communityName: 'Forum $tag',
      );
}

// ID komunitas harus sama dengan yang ada di community_repository.dart.
const String kCommunityUmum = 'comm-1';
const String kCommunityFti = 'comm-2';
const String kCommunityBem = 'comm-3';

class DemoCommunityOption {
  const DemoCommunityOption(this.id, this.name);
  final String id, name;
}

// Sementara, sampai disambungkan ke CommunityRepository.
const List<DemoCommunityOption> kCommunityOptions = <DemoCommunityOption>[
  DemoCommunityOption(kCommunityUmum, 'Umum'),
  DemoCommunityOption(kCommunityFti, 'Informatika FTI'),
  DemoCommunityOption(kCommunityBem, 'Advokasi & BEM'),
];

const List<DemoPost> demoPosts = <DemoPost>[
  DemoPost(
    id: 'thread-1',
    author: 'Rafi Kurniawan',
    tag: 'FTI \'22',
    sub: 'Teknologi Informasi',
    time: '15 mnt lalu',
    title: 'Rekomendasi Dosen Pembimbing untuk Skripsi Machine Learning '
        'di Kampus Limau Manis?',
    body: 'Halo teman-teman FTI! Saya berencana mengambil topik Computer '
        'Vision untuk deteksi penyakit daun kelapa sawit di Sumbar. '
        'Kira-kira dosen pembimbing laboratorium mana yang paling cocok?',
    votes: 42,
    comments: 18,
    communityId: kCommunityFti,
    minutesAgo: 15,
  ),
  DemoPost(
    id: 'thread-2',
    author: 'Aisyah Putri',
    tag: 'FK \'21',
    sub: 'Kedokteran Umum',
    time: '3 jam lalu',
    title: 'Prosedur Pengajuan Cuti Akademik Semester Ganjil via Portal '
        'SIA Unand',
    body: 'Bagi yang perlu menunda semester karena magang MSIB atau alasan '
        'medis, berikut alur permohonan surat keterangan dekanat hingga '
        'persetujuan di sistem.',
    votes: 120,
    comments: 45,
    communityId: kCommunityUmum,
    minutesAgo: 180,
  ),
  DemoPost(
    id: 'thread-3',
    author: 'Dimas Pratama',
    tag: 'FTI \'23',
    sub: 'Sistem Informasi',
    time: '5 jam lalu',
    title: 'KRS error "kuota kelas penuh" padahal slot masih tersedia',
    body: 'Saat input **KRS** untuk mata kuliah Basis Data muncul pesan '
        'kuota penuh, padahal teman sekelas bisa masuk. Ada yang pernah '
        'mengalami hal yang sama?',
    votes: 31,
    comments: 12,
    communityId: kCommunityFti,
    minutesAgo: 300,
  ),
  DemoPost(
    id: 'thread-4',
    author: 'Nabila Rahmadani',
    tag: 'FEB \'22',
    sub: 'Manajemen',
    time: '8 jam lalu',
    title: 'Syarat dan jadwal pendaftaran beasiswa Bidikmisi/KIP-K semester '
        'depan',
    body: 'Ada yang tahu kapan pembukaan beasiswa KIP-K untuk mahasiswa '
        'angkatan 2022? Dokumen apa saja yang perlu disiapkan dari sekarang?',
    votes: 87,
    comments: 0,
    communityId: kCommunityUmum,
    minutesAgo: 480,
  ),
  DemoPost(
    id: 'thread-5',
    author: 'Fajar Nugroho',
    tag: 'FT \'21',
    sub: 'Teknik Sipil',
    time: '1 hari lalu',
    title: 'Rekomendasi kos dekat kampus Limau Manis, budget 500 ribuan',
    body: 'Mau pindah kos bulan depan. Cari yang dekat kampus, wifi bagus, '
        'dan aman. Boleh share pengalaman kalian ya.',
    votes: 56,
    comments: 40,
    communityId: kCommunityUmum,
    minutesAgo: 1440,
  ),
  DemoPost(
    id: 'thread-6',
    author: 'Salsabila Aulia',
    tag: 'FISIP \'22',
    sub: 'Ilmu Politik',
    time: '1 hari lalu',
    title: 'Open recruitment panitia event ormawa: Dies Natalis fakultas',
    body: 'Panitia Dies Natalis membuka pendaftaran divisi acara, humas, '
        'dan dokumentasi. Pendaftaran sampai akhir pekan ini.',
    votes: 24,
    comments: 0,
    communityId: kCommunityBem,
    minutesAgo: 1700,
  ),
  DemoPost(
    id: 'thread-7',
    author: 'Hafizh Alamsyah',
    tag: 'FTI \'21',
    sub: 'Informatika',
    time: '2 hari lalu',
    title: 'Tips lolos seleksi magang MSIB untuk mahasiswa Informatika',
    body: 'Bagi pengalaman dong, portofolio seperti apa yang dilihat '
        'perusahaan dan bagaimana menyiapkan wawancaranya?',
    votes: 120,
    comments: 22,
    communityId: kCommunityFti,
    minutesAgo: 2900,
  ),
  DemoPost(
    id: 'thread-8',
    author: 'Rizky Maulana',
    tag: 'FH \'22',
    sub: 'Ilmu Hukum',
    time: '3 hari lalu',
    title: 'Aspirasi mahasiswa: perbaikan fasilitas parkir dan penerangan '
        'jalan kampus',
    body: 'BEM sedang mengumpulkan aspirasi soal fasilitas kampus. Silakan '
        'tulis keluhan dan usulan kalian di kolom komentar.',
    votes: 64,
    comments: 33,
    communityId: kCommunityBem,
    minutesAgo: 4300,
  ),
];