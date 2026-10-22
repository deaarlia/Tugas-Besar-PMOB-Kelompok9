// lib/widgets/community/thread_widgets.dart
import 'package:flutter/material.dart';
import 'package:unand_space/models/thread_post.dart';
import 'package:unand_space/theme/app_colors.dart';
import 'package:unand_space/theme/app_spacing.dart';
import 'package:unand_space/theme/app_text_styles.dart';
import 'package:unand_space/utils/format.dart';

enum _ThreadAction { togglePin }

/// Titik tiga pada kartu utas. Hanya dipasang untuk moderator dan pembuat.
class ThreadMenuButton extends StatelessWidget {
  const ThreadMenuButton({
    super.key,
    required this.isPinned,
    required this.onTogglePin,
  });

  final bool isPinned;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ThreadAction>(
      tooltip: 'Opsi utas',
      icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
      position: PopupMenuPosition
          .under, // menu muncul di bawah ikon, tidak menimpa kartu
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      onSelected: (_) => onTogglePin(),
      itemBuilder: (_) => <PopupMenuEntry<_ThreadAction>>[
        PopupMenuItem<_ThreadAction>(
          value: _ThreadAction.togglePin,
          child: _MenuRow(
            icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: isPinned ? 'Lepas sematan' : 'Sematkan utas',
          ),
        ),
        const PopupMenuDivider(),
        // Dikerjakan di FR lain (pelaporan utas).
        const PopupMenuItem<_ThreadAction>(
          enabled: false,
          child: _MenuRow(
            icon: Icons.flag_outlined,
            label: 'Laporkan utas',
            enabled: false,
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.textPrimary : AppColors.textHint;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.thread});

  final ThreadPost thread;

  @override
  Widget build(BuildContext context) {
    if (thread.isAnonymous) {
      return const CircleAvatar(
        backgroundColor: Color(0xFFEEF1F6),
        child: Icon(
          Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
      );
    }
    return CircleAvatar(
      backgroundColor: AppColors.chip,
      foregroundColor: AppColors.primary,
      child: Text(
        initialsOf(thread.authorName),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class ThreadCard extends StatelessWidget {
  const ThreadCard({super.key, required this.thread, this.menu});

  final ThreadPost thread;
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AuthorAvatar(thread: thread),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(thread.displayAuthor, style: AppTextStyles.fieldLabel),
                    Text(
                      timeAgo(thread.createdAt),
                      style: AppTextStyles.helper,
                    ),
                  ],
                ),
              ),
              menu ?? const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            thread.body,
            style: AppTextStyles.input.copyWith(fontSize: 15, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.md),
          // Visual saja (voting dan komentar dikerjakan di Modul 3)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chip,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text('${thread.upvotes}', style: AppTextStyles.fieldLabel),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${thread.commentCount} komentar',
                style: AppTextStyles.helper,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PinnedThreadBanner extends StatelessWidget {
  const PinnedThreadBanner({
    super.key,
    required this.thread,
    required this.communityName,
    this.menu,
  });

  final ThreadPost thread;
  final String communityName;
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceTint,
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.push_pin, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISEMATKAN OLEH PENGURUS ${communityName.toUpperCase()} • ${timeAgo(thread.pinnedAt ?? thread.createdAt)}',
                  style: AppTextStyles.sectionCaps.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  thread.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.forum_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${thread.commentCount} balasan',
                      style: AppTextStyles.helper,
                    ),
                  ],
                ),
              ],
            ),
          ),
          menu ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
