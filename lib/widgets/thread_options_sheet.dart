// Paket Flutter Material (widget UI)
import 'package:flutter/material.dart';

// Tema aplikasi (warna dan konstanta)
import '../theme/app_theme.dart';

// =============================================================================
// INPUT / EVENT (FR-04): Bottom sheet opsi konten.
// Menampilkan pilihan aksi untuk utas atau komentar:
//   - "Laporkan": memulai workflow laporan (memanggil callback onReport)
//   - "Sembunyikan": menyembunyikan konten dari linimasa (UI only)
// =============================================================================

/// Bottom sheet opsi konten (gaya Figma "Opsi Utas").
///
/// Contoh utas:
///   showContentOptionsSheet(context, onReport: _openReportForm);
/// Contoh komentar:
///   showContentOptionsSheet(
///     context,
///     title: 'Opsi Komentar',
///     reportLabel: 'Laporkan Komentar',
///     hideLabel: 'Sembunyikan Komentar Ini',
///     onReport: _openReportForm,
///   );
Future<void> showContentOptionsSheet(
  BuildContext context, {
  required VoidCallback onReport, // Callback yang dipanggil saat "Laporkan" dipilih
  String title = 'Opsi Utas',           // Judul sheet (berbeda untuk utas/komentar)
  String reportLabel = 'Laporkan Utas', // Label tombol laporkan
  String hideLabel = 'Sembunyikan Utas Ini', // Label tombol sembunyikan
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
              const Divider(height: 1),
                // INPUT / EVENT: Opsi "Laporkan" — memulai workflow laporan
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.dangerBg,
                  child: Icon(Icons.flag_outlined, color: AppColors.dangerFg),
                ),
                title: Text(
                  reportLabel,
                  style: const TextStyle(
                    color: AppColors.dangerFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Laporan bersifat anonim dan akan diteruskan ke tim '
                  'moderasi UnandSpace untuk ditinjau.',
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop(); // Tutup sheet
                  onReport(); // button Panggil callback untuk buka form laporan
                },
              ),
              // INPUT / EVENT: Opsi "Sembunyikan" (UI only, belum ada fungsi nyata)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.surfaceAlt,
                  child: Icon(Icons.visibility_off_outlined,
                      color: AppColors.textSecondary),
                ),
                title: Text(
                  hideLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Jangan tampilkan ini di beranda Anda lagi.',
                ),
                // Hanya tampilan; belum ada fungsi (di luar workflow tugas).
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  // FEEDBACK: Tampilkan snackbar info bahwa fitur belum tersedia
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur belum tersedia')),
                  );
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}