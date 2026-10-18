// Paket Flutter Material (widget UI)
import 'package:flutter/material.dart';
// Untuk fitur salin ke clipboard (ID laporan)
import 'package:flutter/services.dart';

// Model laporan (data yang ditampilkan di layar sukses)
import '../models/report.dart';
// Tema aplikasi
import '../theme/app_theme.dart';
// Layar "Laporan Saya" (tombol "Lihat Riwayat Laporan")
import 'my_reports_screen.dart';

// =============================================================================
// FEEDBACK + NAVIGATION / RESULT (FR-04): Layar konfirmasi setelah laporan
// berhasil dikirim.
//
// FEEDBACK:
//   - Menampilkan konfirmasi visual bahwa laporan berhasil terkirim.
//   - Menampilkan ID laporan, status "Menunggu", dan tahapan selanjutnya.
//
// NAVIGATION / RESULT:
//   - Tombol "Selesai & Kembali" mengembalikan [report] ke layar sebelumnya.
//   - Tombol "Lihat Riwayat Laporan" membuka layar "Laporan Saya".
// =============================================================================

/// Layar "Status Laporan". Data masuk: [report]. Result keluar: report (pop).
class ReportSuccessScreen extends StatefulWidget {
  const ReportSuccessScreen({super.key, required this.report});

  // Laporan yang berhasil dikirim (diterima dari form laporan)
  final Report report;

  @override
  State<ReportSuccessScreen> createState() => _ReportSuccessScreenState();
}

class _ReportSuccessScreenState extends State<ReportSuccessScreen> {
  // State untuk toggle "Sembunyikan postingan ini" (default: disembunyikan)
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Report report = widget.report;

    return PopScope(
      // Nonaktifkan tombol back sistem agar pengguna wajib tekan "Selesai"
      // dan laporan tetap diteruskan sebagai result ke layar sebelumnya
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Status Laporan'),
              Text('UnandSpace',
                  style: text.bodySmall?.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          actions: const <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.verified_outlined,
                    size: 18, color: AppColors.primary),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.verified, color: Colors.white, size: 38),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('● SELESAI DIPROSES',
                    style: text.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Laporan Berhasil Terkirim',
                textAlign: TextAlign.center,
                style:
                    text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              'Terima kasih telah berkontribusi menjaga kenyamanan dan '
              'keamanan ekosistem Universitas Andalas.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            // ID Laporan dengan tombol salin ke clipboard
            _Row(
              'ID Laporan',
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(report.id,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  // Tombol salin ID laporan ke clipboard
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: report.id));
                      // FEEDBACK: Snackbar konfirmasi salin
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ID laporan disalin')));
                    },
                    child: const Icon(Icons.copy, size: 16),
                  ),
                ],
              ),
            ),
            _Row(
              'Status',
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Sedang Ditinjau Tim Moderasi UnandSpace',
                    style: text.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            _Row(
                'Estimasi Penanganan',
                const Text('Maksimal 1 x 24 Jam Kerja',
                    style: TextStyle(fontWeight: FontWeight.w600))),
            _Row(
              'Privasi',
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.lock, size: 14, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('Anonim 100% (Identitas Anda terlindungi)',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                const Icon(Icons.trending_up,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Tahapan Selanjutnya',
                    style:
                        text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            const _Step(1, 'Penelaahan laporan & bukti tangkapan layar oleh '
                'tim komdis UnandSpace.'),
            const _Step(2, 'Tindakan takedown jika terbukti melanggar kode '
                'etik kampus.'),
            const _Step(3, 'Pembaruan status akan dikirimkan via Notifikasi '
                'di akun Anda.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.visibility_off_outlined,
                      color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Sembunyikan postingan ini',
                            style: text.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text('Tidak akan tampil di linimasa Anda',
                            style: text.bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _hide,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    onChanged: (bool v) => setState(() => _hide = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // NAVIGATION / RESULT: Tombol utama kembali ke layar utas
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                // NAVIGATION / RESULT: kembalikan report ke layar sebelumnya.
                onPressed: () => Navigator.of(context).pop(report),
                child: const Text('Selesai & Kembali'),
              ),
            ),
            // Tombol alternatif untuk membuka "Laporan Saya"
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const MyReportsScreen()),
                ),
                child: const Text('Lihat Riwayat Laporan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(child: Align(alignment: Alignment.centerRight, child: value)),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.n, this.text);

  final int n;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.primaryLight,
            child: Text('$n',
                style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 6, 7, 6))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}