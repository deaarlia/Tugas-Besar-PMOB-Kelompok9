// lib/widgets/community/report_chips.dart
import 'package:flutter/material.dart';
import 'package:tugas_pmob/models/report.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/theme/app_spacing.dart';

Color _reasonFg(ReportReason r) => switch (r) {
  ReportReason.spam => const Color(0xFFD6336C),
  ReportReason.hoax => const Color(0xFFB45F06),
  ReportReason.sara => const Color(0xFF9A3412),
  ReportReason.harassment => const Color(0xFF7E3FBF),
  ReportReason.urgent => AppColors.error,
  ReportReason.other => AppColors.textSecondary,
};

Color _reasonBg(ReportReason r) => switch (r) {
  ReportReason.spam => const Color(0xFFFFE9F0),
  ReportReason.hoax => const Color(0xFFFFF4E0),
  ReportReason.sara => const Color(0xFFFFEDD5),
  ReportReason.harassment => const Color(0xFFF3E8FF),
  ReportReason.urgent => AppColors.errorSurface,
  ReportReason.other => const Color(0xFFEEF1F6),
};

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.fg,
    required this.bg,
    this.dot = false,
    this.icon,
  });

  final String label;
  final Color fg;
  final Color bg;
  final bool dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class ReasonChip extends StatelessWidget {
  const ReasonChip({super.key, required this.reason});

  final ReportReason reason;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      label: reason.label,
      fg: _reasonFg(reason),
      bg: _reasonBg(reason),
      dot: true,
    );
  }
}

class ReportStatusBadge extends StatelessWidget {
  const ReportStatusBadge({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (status) {
      ReportStatus.pending => (AppColors.primary, const Color(0xFFE6F7EC)),
      ReportStatus.rejected => (
        AppColors.textSecondary,
        const Color(0xFFEEF1F6),
      ),
      ReportStatus.deleted => (AppColors.error, AppColors.errorSurface),
    };
    return _Pill(label: status.label, fg: fg, bg: bg, dot: true);
  }
}

class ContentTypeChip extends StatelessWidget {
  const ContentTypeChip({super.key, required this.type});

  final ReportContentType type;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      label: type.label,
      fg: AppColors.textPrimary,
      bg: const Color(0xFFEEF1F6),
      icon: type == ReportContentType.thread
          ? Icons.article_outlined
          : Icons.chat_bubble_outline,
    );
  }
}
