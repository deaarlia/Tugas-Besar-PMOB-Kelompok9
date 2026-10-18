import 'package:flutter/material.dart';
import 'package:unand_space/models/community.dart';
import 'package:unand_space/theme/app_colors.dart';
import 'package:unand_space/theme/app_spacing.dart';
import 'package:unand_space/theme/app_text_styles.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.errorText,
  });

  final CommunityCategory? selected;
  final ValueChanged<CommunityCategory> onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Kategori Organisasi',
                  style: AppTextStyles.fieldLabel,
                  children: const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ),
            const Text('Pilih salah satu', style: AppTextStyles.helper),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final c in CommunityCategory.values)
              ChoiceChip(
                label: Text(c.label),
                selected: c == selected,
                showCheckmark: false,
                avatar: c == selected
                    ? const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.onPrimary,
                      )
                    : null,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.chip,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: c == selected
                      ? AppColors.onPrimary
                      : AppColors.textPrimary,
                ),
                shape: const StadiumBorder(side: BorderSide.none),
                onSelected: (_) => onSelected(c),
              ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(errorText!, style: AppTextStyles.error),
          ),
      ],
    );
  }
}
