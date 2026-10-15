import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ThreadComposerToolbar extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final int maxContent;
  final bool isSubmitting;
  final bool Function() canPost;
  final VoidCallback onAttachPhoto;
  final VoidCallback onAttachDocument;
  final VoidCallback onPost;

  const ThreadComposerToolbar({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.maxContent,
    required this.isSubmitting,
    required this.canPost,
    required this.onAttachPhoto,
    required this.onAttachDocument,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    Widget tool(IconData icon, String tooltip, VoidCallback onPressed) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          tooltip: tooltip,
          onPressed: isSubmitting ? null : onPressed,
          icon: Icon(icon, size: 20),
          style: IconButton.styleFrom(
            foregroundColor: AppColors.primary,
            backgroundColor: AppColors.chipBg,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          tool(Icons.image_outlined, 'Lampirkan foto', onAttachPhoto),
          tool(
            Icons.description_outlined,
            'Lampirkan dokumen (maks. 10 MB)',
            onAttachDocument,
          ),
          const Spacer(),
          ListenableBuilder(
            listenable: Listenable.merge([titleController, contentController]),
            builder: (context, child) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${contentController.text.length}/$maxContent',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: canPost() ? onPost : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Text(
                          'Posting',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
