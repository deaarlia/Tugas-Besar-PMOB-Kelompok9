import 'package:flutter/material.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/theme/app_spacing.dart';
import 'package:tugas_pmob/theme/app_text_styles.dart';

class DangerZone extends StatelessWidget {
  const DangerZone({super.key, required this.onDelete, this.enabled = true});

  final VoidCallback onDelete;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.outline),
        const SizedBox(height: AppSpacing.sm),
        const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Zona Berbahaya',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: enabled ? onDelete : null,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Hapus Komunitas', style: AppTextStyles.button),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerSurface,
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Center(
          child: Text(
            'Komunitas yang dihapus beserta arsip diskusinya tidak dapat dikembalikan.',
            textAlign: TextAlign.center,
            style: AppTextStyles.helper,
          ),
        ),
      ],
    );
  }
}
