import 'package:flutter/material.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/theme/app_spacing.dart';
import 'package:tugas_pmob/theme/app_text_styles.dart';

class GuidelineCard extends StatelessWidget {
  const GuidelineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.primary),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Inisiatif Mahasiswa Unand',
                  style: AppTextStyles.fieldLabel,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Seluruh komunitas yang dibentuk harus mematuhi Kode Etik Sivitas Akademika Universitas Andalas. '
                  'Komunitas terverifikasi BEM/UKM dapat mengajukan lencana resmi melalui admin kemahasiswaan.',
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
