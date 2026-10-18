import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import 'common_widgets.dart';
import 'report_menu.dart';

/// Satu komentar beserta balasannya (maksimal dua tingkat, FR-15).
/// Titik tiga di setiap komentar/balasan membuka menu Laporkan.
class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment, this.isReply = false});

  final Comment comment;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (comment.isBestAnswer) const _BestAnswerBadge(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AuthorAvatar(name: comment.authorName, radius: isReply ? 16 : 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        comment.authorName,
                        style: text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (comment.isThreadAuthor)
                        const InfoChip(
                          'Penulis',
                          background: AppColors.accent,
                          foreground: Colors.white,
                        ),
                      if (comment.authorTag != null)
                        InfoChip(comment.authorTag!),
                    ],
                  ),
                  Text(
                    '${comment.authorInfo} • ${comment.timeAgo}',
                    style: text.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            ReportMenuButton(target: comment.toReportTarget()),
          ],
        ),
        const SizedBox(height: 10),
        MarkedText(comment.body, style: text.bodyMedium?.copyWith(height: 1.4)),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            VotePill(
              score: comment.score,
              onTap: () => showComingSoon(context, 'Fitur vote'),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => showComingSoon(context, 'Fitur balas'),
              icon: const Icon(Icons.reply, size: 18),
              label: const Text('Balas'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        for (final Comment reply in comment.replies)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CommentTile(comment: reply, isReply: true),
          ),
      ],
    );

    if (isReply) {
      // Balasan: garis hijau tipis di kiri, seperti pada desain.
      return Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: Color(0xFFB4D0C9), width: 2),
          ),
        ),
        child: content,
      );
    }
    return content;
  }
}

class _BestAnswerBadge extends StatelessWidget {
  const _BestAnswerBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.check_circle_outline,
                size: 16, color: AppColors.primaryLight),
            SizedBox(width: 6),
            Text(
              'Jawaban Terbaik oleh Penulis',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}