// lib/screens/community/report_queue_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_pmob/models/community.dart';
import 'package:tugas_pmob/models/report.dart';
import 'package:tugas_pmob/repositories/community_repository.dart';
import 'package:tugas_pmob/screens/community/report_detail_screen.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/theme/app_spacing.dart';
import 'package:tugas_pmob/theme/app_text_styles.dart';
import 'package:tugas_pmob/utils/format.dart';
import 'package:tugas_pmob/viewmodels/reports_provider.dart';
import 'package:tugas_pmob/widgets/community/report_chips.dart';

/// Dibuka dari menu titik tiga "Antrean Laporan" (moderator dan pembuat).
class ReportQueueScreen extends StatelessWidget {
  const ReportQueueScreen({super.key, required this.community});

  final Community community;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ReportsProvider(
        repository: ctx.read<CommunityRepository>(),
        communityId: community.id,
      ),
      child: _QueueView(communityName: community.name),
    );
  }
}

class _QueueView extends StatelessWidget {
  const _QueueView({required this.communityName});

  final String communityName;

  void _open(BuildContext context, Report r) {
    final provider = context.read<ReportsProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: ReportDetailScreen(
            reportId: r.id,
            communityName: communityName,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ReportsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Antrean Laporan', style: AppTextStyles.appBarTitle),
            Text(communityName, style: AppTextStyles.helper),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: Center(child: _ModeratorBadge()),
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
                const _FilterBar(),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (p.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (p.loadError != null) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.loadError!, style: AppTextStyles.body),
                              TextButton(
                                onPressed: p.load,
                                child: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        );
                      }
                      final items = p.visible;
                      if (items.isEmpty) return _EmptyState(status: p.filter);
                      return ListView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.filter == ReportStatus.pending
                                      ? 'Menampilkan ${items.length} laporan aktif'
                                      : 'Menampilkan ${items.length} laporan',
                                  style: AppTextStyles.helper,
                                ),
                              ),
                              const Text(
                                'Tekan kartu untuk meninjau',
                                style: AppTextStyles.helper,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          for (final r in items)
                            _ReportCard(
                              report: r,
                              onTap: () => _open(context, r),
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          const _GuidelineCard(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeratorBadge extends StatelessWidget {
  const _ModeratorBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7EC),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: const Color(0xFFBFE8CC)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user, size: 14, color: AppColors.primary),
          SizedBox(width: 6),
          Text(
            'Moderator',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ReportsProvider>();
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final s in ReportStatus.values)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _FilterChip(
                  label: s.label,
                  count: s == ReportStatus.pending ? p.countOf(s) : null,
                  selected: p.filter == s,
                  onTap: () => p.setFilter(s),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onPrimary : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.primary : const Color(0xFFEEF1F6),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w700, color: fg),
              ),
              if (count != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white24 : const Color(0xFFD9DEE8),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});

  final Report report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ContentTypeChip(type: report.contentType),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '• Laporan ${report.code}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.helper,
                      ),
                    ),
                    Text(
                      timeAgo(report.createdAt),
                      style: AppTextStyles.helper,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '“${report.contentText}”',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.input.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1, color: AppColors.outline),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    ReasonChip(reason: report.reason),
                    const SizedBox(width: AppSpacing.sm),
                    ReportStatusBadge(status: report.status),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidelineCard extends StatelessWidget {
  const _GuidelineCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7EC),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: const Color(0xFFBFE8CC)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFCDEFD8),
            child: Icon(Icons.gavel, size: 18, color: AppColors.primary),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedoman Tindakan Moderator',
                  style: AppTextStyles.fieldLabel,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Tinjau bukti laporan secara objektif sesuai aturan komunitas. '
                  'Tolak jika laporan tidak terbukti, hapus jika konten melanggar.',
                  style: AppTextStyles.helper,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final isPending = status == ReportStatus.pending;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7EC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFE8CC)),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isPending
                  ? 'Tidak ada laporan menunggu'
                  : 'Belum ada laporan ${status.label.toLowerCase()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isPending
                  ? 'Semua laporan di komunitas ini sudah diproses.'
                  : 'Laporan dengan status ini akan tampil di sini.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
