import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/attachments.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

class ThreadAttachmentsSection extends StatelessWidget {
  final List<Uint8List> photos;
  final DocumentAttachment? document;
  final bool enabled;
  final ValueChanged<int> onRemovePhoto;
  final VoidCallback onRemoveDocument;

  const ThreadAttachmentsSection({
    super.key,
    required this.photos,
    required this.document,
    required this.enabled,
    required this.onRemovePhoto,
    required this.onRemoveDocument,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty && document == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photos.isNotEmpty) ...[
                Row(
                  children: [
                    const Text(
                      'Lampiran Foto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${photos.length}/${Validators.maxPhotoCount} Foto '
                      '(Maks ${Validators.maxPhotoBytes ~/ (1024 * 1024)} MB)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < photos.length; i++) _photoTile(i),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Format yang didukung: JPG, PNG. Maksimum 3 MB per foto.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (document != null) ...[
                if (photos.isNotEmpty) const SizedBox(height: 16),
                _attachmentCard(
                  title: document!.name,
                  subtitle: document!.sizeLabel,
                  onRemove: onRemoveDocument,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoTile(int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            photos[index],
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: InkWell(
            onTap: enabled ? () => onRemovePhoto(index) : null,
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: AppColors.textDark,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _attachmentCard({
    required String title,
    required String subtitle,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Hapus lampiran',
            onPressed: enabled ? onRemove : null,
          ),
        ],
      ),
    );
  }
}
