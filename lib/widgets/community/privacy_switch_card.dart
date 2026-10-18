import 'package:flutter/material.dart';
import 'package:unand_space/theme/app_colors.dart';
import 'package:unand_space/theme/app_spacing.dart';
import 'package:unand_space/theme/app_text_styles.dart';

class PrivacySwitchCard extends StatelessWidget {
  const PrivacySwitchCard({
    super.key,
    required this.value,
    required this.onChanged,
    this.showHeader = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          const Text(
            'PENGATURAN AKSES & PRIVASI',
            style: AppTextStyles.sectionCaps,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFA6F5B4),
                child: Icon(Icons.public, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Komunitas Terbuka (Publik)',
                      style: AppTextStyles.fieldLabel,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      value
                          ? 'Terbuka untuk seluruh sivitas akademika Universitas Andalas. Postingan dan arsip diskusi dapat dibaca mahasiswa lain.'
                          : 'Hanya anggota yang dapat membaca postingan dan arsip diskusi.', // asumsi, lihat catatan
                      style: AppTextStyles.helper,
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.onPrimary,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
