// lib/widgets/community/delete_content_dialog.dart
import 'package:flutter/material.dart';
import 'package:unand_space/theme/app_colors.dart';
import 'package:unand_space/theme/app_spacing.dart';
import 'package:unand_space/theme/app_text_styles.dart';

class DeleteContentDialog extends StatelessWidget {
  const DeleteContentDialog({super.key, required this.contentLabel});

  /// Contoh: "Utas" atau "Komentar".
  final String contentLabel;

  /// true jika pengguna menekan "Hapus".
  static Future<bool> show(
    BuildContext context, {
    required String contentLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteContentDialog(contentLabel: contentLabel),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
            const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.dangerSurface,
              child: Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Hapus konten ini?',
              style: AppTextStyles.dialogTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$contentLabel yang dilaporkan akan dihapus dan tidak dapat dikembalikan. '
              'Status laporan akan berubah menjadi Dihapus.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.chip,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                    child: const Text('Batal', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus', style: AppTextStyles.button),
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
        ),
      ),
    );
  }
}
