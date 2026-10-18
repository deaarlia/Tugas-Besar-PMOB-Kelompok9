// lib/screens/community/report_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_pmob/models/report.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/theme/app_spacing.dart';
import 'package:tugas_pmob/theme/app_text_styles.dart';
import 'package:tugas_pmob/utils/format.dart';
import 'package:tugas_pmob/viewmodels/reports_provider.dart';
import 'package:tugas_pmob/widgets/community/delete_content_dialog.dart';
import 'package:tugas_pmob/widgets/community/feedback_dialog.dart';
import 'package:tugas_pmob/widgets/community/report_chips.dart';

/// Membutuhkan ReportsProvider di atasnya (disediakan ReportQueueScreen).
class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({
    super.key,
    required this.reportId,
    required this.communityName,
  });

  final String reportId;
  final String communityName;

  Future<void> _reject(BuildContext context) async {
    final p = context.read<ReportsProvider>();
    final navigator = Navigator.of(context);
    final ok = await p.reject(reportId);
    if (!context.mounted) return;
    if (ok) {
      await FeedbackDialog.success(
        context,
        title: 'Laporan ditolak',
        message: 'Konten tetap tampil di komunitas.',
      );
      if (!context.mounted) return;
      navigator.pop();
    } else {
      await FeedbackDialog.error(
        context,
        title: 'Gagal menolak laporan',
        message: p.actionError ?? 'Terjadi kesalahan. Coba lagi.',
      );
    }
  }

  Future<void> _delete(BuildContext context, Report r) async {
    final p = context.read<ReportsProvider>();
    final navigator = Navigator.of(context);
    final confirmed = await DeleteContentDialog.show(
      context,
      contentLabel: r.contentType.label,
    );
    if (!confirmed || !context.mounted) return;
    final ok = await p.deleteContent(reportId);
    if (!context.mounted) return;
    if (ok) {
      await FeedbackDialog.success(
        context,
        title: 'Konten dihapus',
        message: '${r.contentType.label} yang dilaporkan berhasil dihapus.',
      );
      if (!context.mounted) return;
      navigator.pop();
    } else {
      await FeedbackDialog.error(
        context,
        title: 'Gagal menghapus konten',
        message: p.actionError ?? 'Terjadi kesalahan. Coba lagi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ReportsProvider>();
    final r = p.byId(reportId);
    if (r == null) {
      return const Scaffold(
        body: Center(child: Text('Laporan tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Laporan', style: AppTextStyles.appBarTitle),
            Text('Moderasi UnandSpace', style: AppTextStyles.helper),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1F6),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  r.code,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Card(
                          child: Row(
                            children: [
                              ReportStatusBadge(status: r.status),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  '• Komunitas $communityName',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.helper,
                                ),
                              ),
                              Text(
                                timeAgo(r.createdAt),
                                style: AppTextStyles.helper,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ContentCard(report: r),
                        const SizedBox(height: AppSpacing.md),
                        _ReasonCard(report: r),
                      ],
                    ),
                  ),
                ),
                _ActionBar(
                  report: r,
                  busy: p.isBusy,
                  onReject: () => _reject(context),
                  onDelete: () => _delete(context, r),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: child,
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'KONTEN YANG DILAPORKAN',
                style: AppTextStyles.sectionCaps,
              ),
              const Spacer(),
              ContentTypeChip(type: report.contentType),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.chip,
                foregroundColor: AppColors.primary,
                child: Text(
                  initialsOf(report.contentAuthor),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.contentAuthor, style: AppTextStyles.fieldLabel),
                    Text(
                      'Diposting ${timeAgo(report.contentPostedAt)}',
                      style: AppTextStyles.helper,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.surfaceTint,
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 4),
                ),
              ),
              child: Text(
                '“${report.contentText}”',
                style: AppTextStyles.input.copyWith(fontSize: 15, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.outline),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.arrow_upward,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text('${report.upvotes} upvote', style: AppTextStyles.helper),
              const SizedBox(width: AppSpacing.lg),
              const Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${report.commentCount} komentar',
                style: AppTextStyles.helper,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ALASAN PELAPORAN', style: AppTextStyles.sectionCaps),
          const SizedBox(height: AppSpacing.md),
          ReasonChip(reason: report.reason),
          const SizedBox(height: AppSpacing.md),
          Text(report.reason.title, style: AppTextStyles.fieldLabel),
          const SizedBox(height: AppSpacing.xs),
          Text(report.reason.detail, style: AppTextStyles.helper),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.outline),
          const SizedBox(height: AppSpacing.md),
          const Text('Keterangan pelapor:', style: AppTextStyles.fieldLabel),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.outline),
            ),
            child: Text(
              '“${report.reporterNote}”',
              style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 16, color: AppColors.textHint),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Identitas pelapor bersifat anonim & terlindungi sistem.',
                  style: AppTextStyles.helper,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.report,
    required this.busy,
    required this.onReject,
    required this.onDelete,
  });

  final Report report;
  final bool busy;
  final VoidCallback onReject;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final pending = report.status == ReportStatus.pending;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: pending
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tolak: konten tetap tampil • Hapus: konten dihapus permanen',
                  style: AppTextStyles.helper,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : onReject,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Tolak', style: AppTextStyles.button),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: busy ? null : onDelete,
                        icon: busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : const Icon(Icons.delete_outline, size: 18),
                        label: const Text(
                          'Hapus Konten',
                          style: AppTextStyles.button,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ReportStatusBadge(status: report.status),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Laporan ini sudah diproses',
                  style: AppTextStyles.helper,
                ),
              ],
            ),
    );
  }
}
