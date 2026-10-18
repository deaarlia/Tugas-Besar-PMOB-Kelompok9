import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class VoteControl extends StatelessWidget {
  const VoteControl({
    super.key,
    required this.upvoteCount,
    required this.downvoteCount,
    required this.myVote,
    required this.onVote,
    this.compact = false,
  });

  final int upvoteCount;
  final int downvoteCount;
  final int myVote;
  final ValueChanged<int>? onVote;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 16.0 : 18.0;

    Widget voteChip({
      required int value,
      required int count,
      required IconData icon,
      required String tooltip,
    }) {
      final selected = myVote == value;
      final color = value == 1 ? AppColors.primary : AppColors.error;
      return Tooltip(
        message: tooltip,
        child: Material(
          key: ValueKey('vote-chip-$value'),
          color: selected ? color.withValues(alpha: 0.14) : Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            key: ValueKey('vote-action-$value'),
            customBorder: const StadiumBorder(),
            onTap: onVote == null ? null : () => onVote!(value),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 9 : 11,
                vertical: compact ? 5 : 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: iconSize,
                    color: selected ? color : AppColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: selected ? color : AppColors.textMuted,
                      fontSize: AppTypography.label,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        voteChip(
          value: 1,
          count: upvoteCount,
          icon: Icons.arrow_upward,
          tooltip: 'Upvote',
        ),
        const SizedBox(width: 4),
        voteChip(
          value: -1,
          count: downvoteCount,
          icon: Icons.arrow_downward,
          tooltip: 'Downvote',
        ),
      ],
    );
  }
}
