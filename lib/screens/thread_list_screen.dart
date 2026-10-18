import 'package:flutter/material.dart';

import '../data/placeholder_data.dart';
import '../models/thread.dart';
import '../theme/app_theme.dart';
import '../widgets/thread_card.dart';
import 'my_reports_screen.dart';
import 'thread_detail_screen.dart';

/// Layar awal demo: satu kartu utas (gaya Beranda) dan tombol "Laporan Saya".
class ThreadListScreen extends StatelessWidget {
  const ThreadListScreen({super.key});

  static const Thread _demoThread = Thread(
    id: 'thread-1',
    authorName: 'Rafi Kurniawan',
    authorInfo: 'Teknologi Informasi \'22',
    timeAgo: '15 menit lalu',
    title: 'Rekomendasi Dosen Pembimbing untuk Skripsi Machine Learning di Kampus Limau Manis?',
    body: 'Halo teman-teman FTI! Saya berencana mengambil topik Computer Vision untuk deteksi penyakit daun kelapa sawit di Sumbar. Kira-kira dosen pembimbing laboratorium mana yang paling cocok?',
    score: 42,
    commentCount: 18,
    communityName: 'Forum FTI \'22',
    isAuthorOnline: true,
  );

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UnandSpace'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MyReportsScreen(),
              ),
            ),
            icon: const Icon(Icons.flag_outlined, size: 20),
            label: const Text('Laporan Saya'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Demo Laporkan Konten (FR-04). Tekan ⋮ pada kartu, atau buka '
              'utas lalu tekan ⋮ pada utas atau komentar.',
              style: text.bodySmall?.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          ThreadCard(
            thread: _demoThread,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ThreadDetailScreen(post: demoPosts.first),
              ),
            ),
          ),
        ],
      ),
    );
  }
}