// Paket Flutter Material (widget UI)
import 'package:flutter/material.dart';

// Model laporan (digunakan untuk hasil dari showReportFlow)
import '../models/report.dart';
// Model target laporan
import '../models/report_target.dart';
// Layar "Laporan Saya" (dibuka dari snackbar)
import '../screens/my_reports_screen.dart';
// Form laporan yang dibuka saat pengguna menekan "Laporkan"
import '../screens/report_form_screen.dart';

// =============================================================================
// INPUT / EVENT (FR-04): Tombol titik tiga (⋮) yang memulai workflow laporan.
// Dipakai di kartu utas, app bar detail utas, dan setiap komentar.
// =============================================================================

/// Tombol titik tiga (⋮) yang membuka sheet "Opsi Utas" / "Opsi Komentar".
/// Dipakai di kartu utas, app bar detail utas, dan setiap komentar.
class ReportMenuButton extends StatelessWidget {
  const ReportMenuButton({super.key, required this.target});

  // Data konten yang akan dilaporkan (dikirim ke form laporan)
  final ReportTarget target;

  @override
  Widget build(BuildContext context) {
    // Ambil label tipe konten dalam huruf kecil (contoh: "utas", "komentar")
    final String type = target.type.label.toLowerCase();

    return IconButton(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Opsi $type',
      visualDensity: VisualDensity.compact,
      onPressed: () {
        // INPUT / EVENT: Tampilkan bottom sheet opsi saat tombol ditekan
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (BuildContext sheetContext) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      'Opsi ${target.type.label}',
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                  ),
                  // INPUT / EVENT: Tombol "Laporkan" di dalam sheet
                  ListTile(
                    leading: Icon(
                      Icons.flag_outlined,
                      color: Theme.of(sheetContext).colorScheme.error,
                    ),
                    title: Text('Laporkan $type'),
                    onTap: () {
                      Navigator.of(sheetContext).pop(); // tutup sheet
                      showReportFlow(context, target); // buka form laporan
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// INPUT / EVENT → NAVIGATION → FEEDBACK (FR-04):
// Titik masuk tunggal workflow "Laporkan Konten".
//
// Semua tombol Laporkan memanggil fungsi ini.
//   1. NAVIGATION: kirim [target] ke ReportFormScreen.
//   2. Tunggu hasil dari form (Report jika berhasil, null jika dibatalkan).
//   3. FEEDBACK: snackbar "Laporan berhasil dikirim" di layar pemanggil.
//   4. NAVIGATION / RESULT: Link "Lihat" di snackbar membuka "Laporan Saya".
// =============================================================================
/// Titik masuk tunggal workflow "Laporkan Konten".
///
/// Semua tombol Laporkan memanggil fungsi ini.
///   1. NAVIGATION: kirim [target] ke ReportFormScreen.
///   2. Tunggu hasil dari form (Report jika berhasil, null jika dibatalkan).
///   3. FEEDBACK: snackbar "Laporan berhasil dikirim" di layar pemanggil.
Future<void> showReportFlow(BuildContext context, ReportTarget target) async {
  // Ambil dulu sebelum await, supaya tidak memakai context sesudah jeda async.
  final NavigatorState navigator = Navigator.of(context);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

  // Debug log untuk melacak alur (hanya muncul di mode debug)
  debugPrint('[Laporkan] kirim ke form  -> $target');

  // NAVIGATION: Buka form laporan dan tunggu hasilnya
  final Report? report = await navigator.push<Report>(
    MaterialPageRoute<Report>(
      builder: (_) => ReportFormScreen(target: target),
    ),
  );

  if (report == null) {
    // Pengguna menutup form tanpa mengirim laporan
    debugPrint('[Laporkan] form ditutup tanpa mengirim laporan');
    return;
  }

  // Debug log hasil laporan yang diterima dari form
  debugPrint('[Laporkan] hasil dari form <- ${report.toJson()}');

  // FEEDBACK: Tampilkan snackbar "Laporan berhasil dikirim"
  // dengan aksi "Lihat" yang membuka layar "Laporan Saya"
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text('Laporan berhasil dikirim'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Lihat',
          onPressed: () {
            // NAVIGATION / RESULT: Buka layar "Laporan Saya"
            // untuk melihat laporan baru dengan status "Menunggu"
            navigator.push(
              MaterialPageRoute<void>(builder: (_) => const MyReportsScreen()),
            );
          },
        ),
      ),
    );
}
