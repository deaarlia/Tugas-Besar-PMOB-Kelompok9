import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../models/report_target.dart';
import '../viewmodels/my_reports_view_model.dart';
import '../theme/app_theme.dart';
import '../theme/report_status_style.dart';
import '../utils/time_ago.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MyReportsViewModel>().resetFilter();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MyReportsViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final MyReportsViewModel state = context.watch<MyReportsViewModel>();
    final TextTheme text = Theme.of(context).textTheme;

    final List<Report> shown = state.filteredReports;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Status Laporan'),
            Text('UnandSpace',
                style: text.bodySmall?.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text('Laporan Saya',
                      style: text.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('● ${state.reports.length} Laporan',
                      style: text.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text('Pantau status dan tindak lanjut laporan moderasi Anda',
                style: text.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
          ),
          // Tab filter status laporan (scroll horizontal)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                // Tab "Semua": tampilkan semua laporan tanpa filter
                _Tab('Semua', null, state.selectedStatus == null,
                    () => state.selectStatus(null)),
                // Tab "Menunggu": filter laporan dengan status Menunggu
                _Tab('Menunggu Ditinjau', state.countOf(ReportStatus.menunggu),
                    state.selectedStatus == ReportStatus.menunggu,
                    () => state.selectStatus(ReportStatus.menunggu)),
                // Tab "Diproses": filter laporan dengan status Diproses
                _Tab('Diproses', state.countOf(ReportStatus.diproses),
                    state.selectedStatus == ReportStatus.diproses,
                    () => state.selectStatus(ReportStatus.diproses)),
                // Tab "Ditolak": filter laporan dengan status Ditolak
                _Tab('Ditolak', state.countOf(ReportStatus.ditolak),
                    state.selectedStatus == ReportStatus.ditolak,
                    () => state.selectStatus(ReportStatus.ditolak)),
              ],
            ),
          ),
          // Konten utama: spinner / error / daftar laporan
          Expanded(child: _body(state, shown)),
        ],
      ),
    );
  }

  // Menentukan konten yang ditampilkan berdasarkan state provider
  Widget _body(MyReportsViewModel state, List<Report> shown) {
    // STATE: Sedang memuat data
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // STATE: Gagal memuat (koneksi error, dll)
    if (state.error != null) {
      return _Message(
        icon: Icons.wifi_off,
        text: state.error!,
        // FEEDBACK: Tombol "Coba lagi" untuk memuat ulang
        action:
            FilledButton(onPressed: state.load, child: const Text('Coba lagi')),
      );
    }
    // STATE: Tidak ada laporan yang cocok dengan filter
    if (shown.isEmpty) {
      return const _Message(
        icon: Icons.flag_outlined,
        text: 'Belum ada laporan.\nLaporan yang kamu kirim akan muncul di sini.',
      );
    }
    // STATE: Daftar laporan berhasil dimuat
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: shown.length + 1, // +1: kartu "Kerahasiaan Terjamin"
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      // Tampilkan item laporan atau kartu privasi di akhir daftar
      itemBuilder: (_, int i) => i < shown.length
          ? _ReportItem(report: shown[i])
          : const _PrivacyCard(),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.label, this.badge, this.active, this.onTap);

  final String label;
  final int? badge;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: <Widget>[
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.textSecondary)),
              if (badge != null) ...<Widget>[
                const SizedBox(width: 6),
                Text('$badge',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            active ? Colors.white : AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  const _ReportItem({required this.report});

  final Report report;

  String get _sourceLabel {
    final String? community = report.targetCommunityName;
    if (report.targetType == ReportTargetType.thread && community != null) {
      return 'Utas di $community';
    }
    return '${report.targetType.label} oleh ${report.targetAuthorName}';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.divider.withValues(alpha: 0.9),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: report.status.bg,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.forum_outlined,
                          size: 16, color: report.status.fg),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _sourceLabel,
                          overflow: TextOverflow.ellipsis,
                          style: text.labelMedium?.copyWith(
                            color: report.status.fg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: report.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Row(
                  children: <Widget>[
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo(report.createdAt),
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.chipBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.flag_outlined,
                              size: 11, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            report.reason.label.split(' / ').first,
                            style: text.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: report.status.fg,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    '"${report.targetExcerpt}"',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                if (report.description != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.notes,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          report.description!,
                          style: text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                _Note(status: report.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final Color bg = status.bg;
    final Color fg = status.fg;
    final IconData icon = status.icon;
    final String label = switch (status) {
      ReportStatus.menunggu => 'Dalam Peninjauan',
      ReportStatus.diproses => 'Selesai Dihapus',
      ReportStatus.ditolak => 'Ditolak (Valid)',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final (Color bg, Color fg, IconData icon, String title, String body) =
        switch (status) {
      ReportStatus.menunggu => (
          AppColors.surfaceAlt,
          AppColors.statusWaitingFg,
          Icons.schedule,
          'STATUS PENANGANAN',
          'Laporan telah masuk antrean pemeriksaan tim moderator.',
        ),
      ReportStatus.diproses => (
          AppColors.primaryLight,
          AppColors.primary,
          Icons.shield_outlined,
          'TINDAKAN SELESAI',
          'Moderator menyetujui laporan Anda. Konten telah dihapus dan '
              'pelanggar diberi sanksi.',
        ),
      ReportStatus.ditolak => (
          AppColors.statusProcessBg,
          AppColors.statusProcessFg,
          Icons.info_outline,
          'KETERANGAN VERIFIKASI',
          'Setelah ditinjau, konten tidak melanggar ketentuan.',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: text.labelSmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4)),
                const SizedBox(height: 2),
                Text(body, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_outline,
                size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('Kerahasiaan Terjamin',
                        style: text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified,
                        size: 16, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Identitas Anda sebagai pelapor selalu dienkripsi dan '
                  'dirahasiakan demi keamanan dan kenyamanan bersama seluruh '
                  'civitas akademika Universitas Andalas.',
                  style: text.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...<Widget>[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}