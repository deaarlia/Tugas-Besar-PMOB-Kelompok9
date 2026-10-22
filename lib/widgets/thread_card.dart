import 'package:flutter/material.dart';

import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'vote_control.dart';

class ThreadCard extends StatelessWidget {
  final ThreadPost thread;
  final bool isOwnPost;
  final bool isFollowed;
  final VoidCallback onToggleFollow;
  final VoidCallback? onOpenDetails;
  final ValueChanged<int>? onVote;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDetail;

  const ThreadCard({
    super.key,
    required this.thread,
    required this.isOwnPost,
    required this.isFollowed,
    required this.onToggleFollow,
    this.onOpenDetails,
    this.onVote,
    this.onEdit,
    this.onDelete,
    this.isDetail = false,
  });

  @override
  Widget build(BuildContext context) {
    final anon = thread.isAnonymous;
    return InkWell(
      onTap: onOpenDetails,
      child: Container(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFEBEFF2), width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Foto Profil & Info Pengguna
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: anon ? AppColors.chipBg : AppColors.avatarBg,
                  child: anon
                      ? const Icon(
                          Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                          size: 18,
                        )
                      : Text(
                          UserProfile.initialsOf(thread.authorName),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: AppTypography.label,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          thread.displayAuthor,
                          style: const TextStyle(
                            fontSize: AppTypography.body,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (!anon && thread.authorBadge.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.chipBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              thread.authorBadge,
                              style: const TextStyle(
                                fontSize: AppTypography.micro,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F4E8C),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${thread.timeLabel}${thread.isEdited ? ' · diedit' : ''}',
                      style: const TextStyle(
                        fontSize: AppTypography.caption,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (!isOwnPost && !anon)
                  OutlinedButton(
                    onPressed: onToggleFollow,
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      minimumSize: const Size(0, 28),
                      backgroundColor: isFollowed
                          ? AppColors.chipBg
                          : Colors.white,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      isFollowed ? 'Mengikuti' : '+ Ikuti',
                      style: const TextStyle(
                        fontSize: AppTypography.caption,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Opsi postingan',
                  onSelected: (action) {
                    if (action == 'edit') {
                      onEdit?.call();
                    } else if (action == 'delete') {
                      onDelete?.call();
                    } else if (action == 'report') {
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Laporkan postingan'),
                          content: const Text(
                            'Fitur pelaporan postingan belum tersedia.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tutup'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => isOwnPost
                      ? const [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit utas'),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Hapus utas'),
                          ),
                        ]
                      : const [
                          PopupMenuItem<String>(
                            value: 'report',
                            child: Text('Laporkan postingan'),
                          ),
                        ],
                  icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Judul Postingan (lebar penuh di bawah profil)
            Text(
              thread.title,
              style: const TextStyle(
                fontSize: AppTypography.sectionTitle,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.avatarBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                thread.community,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: AppTypography.micro,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Isi Postingan
            if (isDetail)
              Text(thread.content, style: _threadContentStyle)
            else
              _ThreadContentPreview(content: thread.content),
            if (thread.topics.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 2,
                children: thread.topics
                    .map(
                      (t) => Text(
                        '#$t',
                        style: const TextStyle(
                          fontSize: AppTypography.caption,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            // Media Grid untuk Foto
            if (thread.photoCount > 0) ...[
              const SizedBox(height: 10),
              _buildPhotoGrid(),
            ],
            // Lampiran dokumen
            if (thread.document != null) ...[
              const SizedBox(height: 10),
              _infoTile(
                Icons.description_outlined,
                '${thread.document!.name} • ${thread.document!.sizeLabel}',
              ),
            ],
            const SizedBox(height: 10),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _photoItem(int index) {
    if (index < thread.photos.length) {
      return Image.memory(
        thread.photos[index],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Container(
      color: AppColors.chipBg,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 28, color: AppColors.textMuted),
      ),
    );
  }

  /// Media Grid layout ala X/Twitter:
  /// - 1 foto: AspectRatio 16:9 penuh dengan sudut membulat
  /// - 2 foto: 2 kolom berdampingan
  /// - 3 foto: 1 foto besar di kiri, 2 foto bertumpuk di kanan
  Widget _buildPhotoGrid() {
    final total = thread.photoCount;

    if (total == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(aspectRatio: 16 / 9, child: _photoItem(0)),
      );
    }

    if (total == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Row(
            children: [
              Expanded(child: _photoItem(0)),
              const SizedBox(width: 3),
              Expanded(child: _photoItem(1)),
            ],
          ),
        ),
      );
    }

    // 3 atau lebih foto: 1 besar di kiri, 2 bertumpuk di kanan
    final extra = total - 3;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Row(
          children: [
            Expanded(flex: 1, child: _photoItem(0)),
            const SizedBox(width: 3),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(child: _photoItem(1)),
                  const SizedBox(height: 3),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _photoItem(2),
                        if (extra > 0)
                          Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: Text(
                              '+$extra',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: AppTypography.sectionTitle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: AppTypography.label,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        VoteControl(
          upvoteCount: thread.upvoteCount,
          downvoteCount: thread.downvoteCount,
          myVote: thread.myVote,
          onVote: onVote,
          compact: true,
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              '${thread.comments}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: AppTypography.caption,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        const Icon(Icons.share_outlined, size: 16, color: AppColors.textMuted),
      ],
    );
  }
}

const _threadContentStyle = TextStyle(
  fontSize: AppTypography.body,
  height: 1.45,
  color: Color(0xFF374151),
);

class _ThreadContentPreview extends StatelessWidget {
  const _ThreadContentPreview({required this.content});

  static const int _maxLines = 4;
  static const String _readMore = '... selebihnya';
  static const TextStyle _readMoreStyle = TextStyle(
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  final String content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = DefaultTextStyle.of(context).style
            .merge(_threadContentStyle);
        final textScaler = MediaQuery.textScalerOf(context);
        final textDirection = Directionality.of(context);
        final characters = content.runes.toList(growable: false);

        TextSpan spanFor(int characterCount) {
          final prefix = String.fromCharCodes(characters.take(characterCount))
              .trimRight();
          return TextSpan(
            style: textStyle,
            children: [
              TextSpan(text: prefix),
              const TextSpan(text: _readMore, style: _readMoreStyle),
            ],
          );
        }

        bool exceedsMaxLines(InlineSpan span) {
          final painter = TextPainter(
            text: span,
            textDirection: textDirection,
            textScaler: textScaler,
            maxLines: _maxLines,
            ellipsis: '\u2026',
          )..layout(maxWidth: constraints.maxWidth);
          final exceeds = painter.didExceedMaxLines;
          painter.dispose();
          return exceeds;
        }

        final fullTextPainter = TextPainter(
          text: TextSpan(text: content, style: textStyle),
          textDirection: textDirection,
          textScaler: textScaler,
          maxLines: _maxLines,
          ellipsis: '\u2026',
        )..layout(maxWidth: constraints.maxWidth);
        final isTruncated = fullTextPainter.didExceedMaxLines;
        fullTextPainter.dispose();

        final span = isTruncated
            ? spanFor(
                _largestFittingPrefix(
                  characters.length,
                  spanFor,
                  exceedsMaxLines,
                ),
              )
            : TextSpan(text: content, style: textStyle);

        return RichText(
          text: span,
          maxLines: _maxLines,
          overflow: TextOverflow.clip,
          textDirection: textDirection,
          textScaler: textScaler,
        );
      },
    );
  }

  int _largestFittingPrefix(
    int characterCount,
    TextSpan Function(int) spanFor,
    bool Function(InlineSpan) exceedsMaxLines,
  ) {
    var low = 0;
    var high = characterCount;
    while (low < high) {
      final middle = (low + high + 1) ~/ 2;
      if (exceedsMaxLines(spanFor(middle))) {
        high = middle - 1;
      } else {
        low = middle;
      }
    }
    return low;
  }
}
