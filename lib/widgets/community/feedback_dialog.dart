import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/theme/app_spacing.dart';
import 'package:tugas_pmob/theme/app_text_styles.dart';

enum FeedbackType { success, error }

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.duration,
  });

  final FeedbackType type;
  final String title;
  final String message;
  final Duration duration;

  static Future<void> show(
    BuildContext context, {
    required FeedbackType type,
    required String title,
    required String message,
    Duration? duration,
  }) {
    // Pesan gagal diberi waktu baca sedikit lebih lama.
    final d =
        duration ??
        (type == FeedbackType.success
            ? const Duration(milliseconds: 1500)
            : const Duration(milliseconds: 2500));
    return showDialog<void>(
      context: context,
      builder: (_) => FeedbackDialog(
        type: type,
        title: title,
        message: message,
        duration: d,
      ),
    );
  }

  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return show(
      context,
      type: FeedbackType.success,
      title: title,
      message: message,
    );
  }

  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return show(
      context,
      type: FeedbackType.error,
      title: title,
      message: message,
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    // Jika pop-up ditutup lebih awal (ketuk di luar), timer dibatalkan
    // supaya tidak menutup layar lain.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.type == FeedbackType.success;
    final accent = isSuccess ? AppColors.primary : AppColors.error;
    final accentSurface = isSuccess
        ? const Color(0xFFA6F5B4)
        : AppColors.dangerSurface;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg + 8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: accentSurface,
              child: Icon(
                isSuccess ? Icons.check_rounded : Icons.error_outline,
                color: accent,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.title,
              style: AppTextStyles.dialogTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.message,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
