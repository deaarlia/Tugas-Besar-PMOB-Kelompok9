import 'package:flutter/material.dart';
import '../models/report.dart';
import 'app_theme.dart';

/// Warna dan ikon status laporan di satu tempat (sebelumnya tersebar di
/// beberapa switch pada layar "Laporan Saya").
extension ReportStatusStyle on ReportStatus {
  Color get fg => switch (this) {
        ReportStatus.menunggu => AppColors.statusWaitingFg,
        ReportStatus.diproses => AppColors.statusProcessFg,
        ReportStatus.ditolak => AppColors.statusRejectedFg,
      };

  Color get bg => switch (this) {
        ReportStatus.menunggu => AppColors.statusWaitingBg,
        ReportStatus.diproses => AppColors.statusProcessBg,
        ReportStatus.ditolak => AppColors.statusRejectedBg,
      };

  IconData get icon => switch (this) {
        ReportStatus.menunggu => Icons.hourglass_bottom,
        ReportStatus.diproses => Icons.sync,
        ReportStatus.ditolak => Icons.block,
      };
}
