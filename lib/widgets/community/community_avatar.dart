import 'package:flutter/material.dart';
import 'package:tugas_pmob/models/community.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/utils/image_source.dart';

class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({super.key, required this.community, this.radius = 24});

  final Community community;
  final double radius;

  String get _initials {
    final words = community.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => RegExp(r'^[\p{L}\p{N}]', unicode: true).hasMatch(w));
    if (words.isEmpty) return '?';
    return words.take(2).map((w) => w[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final image = imageProviderFor(community.iconUrl);
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.chip,
      foregroundColor: AppColors.primary,
      backgroundImage: image,
      child: image == null
          ? Text(_initials, style: const TextStyle(fontWeight: FontWeight.w800))
          : null,
    );
  }
}
