import 'package:flutter/material.dart';
import '../models/community.dart';
import '../viewmodels/community_list_view_model.dart';

/// Alur tombol Gabung / Mengikuti, dipakai bersama oleh layar Jelajah dan
/// layar Detail komunitas.
/// - Belum mengikuti -> langsung bergabung.
/// - Sudah mengikuti -> tampilkan dialog konfirmasi "Keluar Komunitas".
void handleCommunityFollowTap(
  BuildContext context,
  CommunityListViewModel provider,
  Community community,
) {
  if (community.isFollowing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar Komunitas'),
        content: Text('Apakah Anda yakin ingin keluar dari komunitas ${community.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.toggleFollow(community.id);
              Navigator.pop(ctx);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  } else {
    provider.toggleFollow(community.id);
  }
}
