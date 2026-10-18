import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Avatar lingkaran berisi inisial (foto profil belum tersedia).
class AuthorAvatar extends StatelessWidget {
  const AuthorAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.showOnlineDot = false,
  });

  final String name;
  final double radius;
  final bool showOnlineDot;

  static const List<Color> _palette = <Color>[
    Color(0xFF3F7D5B),
    Color(0xFF4F6FA8),
    Color(0xFF8A6A3B),
    Color(0xFF7A5C99),
    Color(0xFF3B8A8A),
  ];

  @override
  Widget build(BuildContext context) {
    final int seed = name.codeUnits.fold<int>(0, (int a, int b) => a + b);
    final Color color = _palette[seed % _palette.length];
    final String initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        CircleAvatar(
          radius: radius,
          backgroundColor: color,
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: radius * 0.8,
            ),
          ),
        ),
        if (showOnlineDot)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: const Color(0xFF2EBD59),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// Label kecil berbentuk pil (fakultas, organisasi, "Penulis", dan sebagainya).
class InfoChip extends StatelessWidget {
  const InfoChip(
    this.text, {
    super.key,
    this.background = AppColors.chipBackground,
    this.foreground = AppColors.primary,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

/// Teks yang menebalkan bagian di antara `**`, contoh: "a **tebal** b".
class MarkedText extends StatelessWidget {
  const MarkedText(this.text, {super.key, this.style, this.maxLines});

  final String text;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = style ?? Theme.of(context).textTheme.bodyMedium!;
    final List<String> parts = text.split('**');
    return Text.rich(
      TextSpan(
        style: base,
        children: <InlineSpan>[
          for (int i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w700) : null,
            ),
        ],
      ),
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
    );
  }
}

/// Pil skor (panah atas, angka, panah bawah). Tampil saja:
/// TODO Modul 3 (FR-16) menyambungkan aksi upvote/downvote.
class VotePill extends StatelessWidget {
  const VotePill({super.key, required this.score, this.onTap});

  final int score;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.arrow_upward, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              '$score',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_downward,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}