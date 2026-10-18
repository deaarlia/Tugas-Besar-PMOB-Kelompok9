import 'package:flutter/material.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/theme/app_spacing.dart';
import 'package:tugas_pmob/theme/app_text_styles.dart';

class DeleteCommunityDialog extends StatelessWidget {
  const DeleteCommunityDialog({super.key, required this.communityName});

  final String communityName;

  static Future<bool> show(
    BuildContext context, {
    required String communityName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteCommunityDialog(communityName: communityName),
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
              child: Icon(Icons.delete_sweep, color: AppColors.error, size: 32),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Hapus komunitas ini?',
              style: AppTextStyles.dialogTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text.rich(
              TextSpan(
                style: AppTextStyles.body,
                children: [
                  const TextSpan(text: 'Komunitas '),
                  TextSpan(
                    text: communityName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const TextSpan(
                    text: ' beserta seluruh utas dan arsip medianya akan dihapus secara permanen dan tidak dapat dikembalikan.',
                  ),
                ],
              ),
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
