import 'package:flutter/material.dart';
import 'package:unand_space/theme/app_colors.dart';
import 'package:unand_space/theme/app_spacing.dart';
import 'package:unand_space/theme/app_text_styles.dart';
import 'package:unand_space/utils/image_source.dart';

class CoverIconPicker extends StatelessWidget {
  const CoverIconPicker({
    super.key,
    required this.onPickCover,
    required this.onPickIcon,
    this.coverPath,
    this.coverUrl,
    this.iconPath,
    this.iconUrl,
  });

  final VoidCallback onPickCover;
  final VoidCallback onPickIcon;
  final String? coverPath;
  final String? coverUrl;
  final String? iconPath;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final cover = imageProviderFor(coverPath ?? coverUrl);
    final icon = imageProviderFor(iconPath ?? iconUrl);
    const half = AppSpacing.iconAvatar / 2;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: half),
          child: AspectRatio(
            aspectRatio: AppSpacing.coverAspectRatio,
            child: Material(
              color: AppColors.surfaceTint,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                side: const BorderSide(color: AppColors.outline),
              ),
              child: InkWell(
                onTap: onPickCover,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (cover != null)
                      Image(image: cover, fit: BoxFit.cover)
                    else
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Unggah Sampul',
                              style: AppTextStyles.fieldLabel,
                            ),
                            Text(
                              'Rasio 16:9 disarankan (Maks 5 MB)',
                              style: AppTextStyles.helper,
                            ),
                          ],
                        ),
                      ),
                    if (cover != null)
                      Positioned(
                        right: AppSpacing.md,
                        bottom: AppSpacing.md,
                        child: Chip(
                          avatar: const Icon(
                            Icons.photo_camera_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Ganti Sampul',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: AppColors.surface,
                          side: BorderSide.none,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          bottom: 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: AppSpacing.iconAvatar,
                height: AppSpacing.iconAvatar,
                child: Material(
                  color: AppColors.chip,
                  shape: const CircleBorder(
                    side: BorderSide(color: AppColors.surface, width: 3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: icon == null
                      ? InkWell(
                          onTap: onPickIcon,
                          child: const Center(
                            child: Icon(
                              Icons.groups,
                              color: AppColors.primary,
                              size: 36,
                            ),
                          ),
                        )
                      : Ink.image(
                          image: icon,
                          fit: BoxFit.cover,
                          child: InkWell(onTap: onPickIcon),
                        ),
                ),
              ),
              const Positioned(
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.photo_camera,
                      size: 14,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
