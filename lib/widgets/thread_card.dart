import 'package:flutter/material.dart';

import '../models/thread.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import 'common_widgets.dart';
import 'report_menu.dart';

/// Kartu utas untuk daftar utas. Titik tiga membuka menu Laporkan.
class ThreadCard extends StatelessWidget {
  const ThreadCard({super.key, required this.thread, required this.onTap});

  final Thread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 4, 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  AuthorAvatar(
                    name: thread.authorName,
                    showOnlineDot: thread.isAuthorOnline,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          thread.authorName,
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${thread.authorInfo} • ${thread.timeAgo}',
                          style: text.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => showComingSoon(context, 'Fitur Ikuti'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('+ Ikuti'),
                  ),
                  ReportMenuButton(target: thread.toReportTarget()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 12),
                    Text(
                      thread.title,
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      thread.body.split('\n').first,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        VotePill(
                          score: thread.score,
                          onTap: () => showComingSoon(context, 'Fitur vote'),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.chat_bubble_outline,
                            size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text('${thread.commentCount} Komentar',
                            style: text.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
