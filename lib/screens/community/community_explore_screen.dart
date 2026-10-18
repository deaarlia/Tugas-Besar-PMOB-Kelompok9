// lib/screens/community/community_explore_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unand_space/models/community.dart';
import 'package:unand_space/models/thread_post.dart';
import 'package:unand_space/models/user_profile.dart';
import 'package:unand_space/repositories/community_repository.dart';
import 'package:unand_space/screens/community/community_detail_screen.dart';
import 'package:unand_space/screens/community/create_community_screen.dart';
import 'package:unand_space/routes/app_routes.dart';
import 'package:unand_space/theme/app_colors.dart';
import 'package:unand_space/theme/app_spacing.dart';
import 'package:unand_space/theme/app_text_styles.dart';
import 'package:unand_space/widgets/app_bottom_nav.dart';
import 'package:unand_space/widgets/community/community_avatar.dart';

/// Titik awal workflow Buat Komunitas.
class CommunityExploreScreen extends StatefulWidget {
  const CommunityExploreScreen({super.key});

  @override
  State<CommunityExploreScreen> createState() => _CommunityExploreScreenState();
}

class _CommunityExploreScreenState extends State<CommunityExploreScreen> {
  late Future<List<Community>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CommunityRepository>().list();
  }

  void _reload() {
    setState(() {
      _future = context.read<CommunityRepository>().list();
    });
  }

  Future<void> _openDetail(Community community) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityDetailScreen(community: community),
      ),
    );
    // Detail bisa mengubah atau menghapus komunitas, jadi muat ulang daftar.
    if (mounted) _reload();
  }

  Future<void> _openCreate() async {
    final result = await Navigator.of(context).push<CommunityFormResult>(
      MaterialPageRoute(builder: (_) => const CreateCommunityScreen()),
    );
    if (!mounted) return;
    _reload();
    final created = result?.community;
    if (created != null) await _openDetail(created);
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context)
            .pushNamedAndRemoveUntil<void>(AppRoutes.home, (_) => false);
        return;
      case 1:
        return;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Halaman notifikasi belum tersedia.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      case 3:
        Navigator.of(context)
            .pushNamed<void>(AppRoutes.profile, arguments: UserProfile.demo);
        return;
    }
  }

  Future<void> _openCreateThread() async {
    final created = await Navigator.of(context).pushNamed<ThreadPost>(
      AppRoutes.createThread,
      arguments: UserProfile.demo,
    );
    if (!mounted || created == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Postingan berhasil dibuat!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Jelajah Komunitas',
                          style: AppTextStyles.appBarTitle,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _openCreate,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Buat', style: AppTextStyles.button),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Community>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Gagal memuat komunitas',
                                style: AppTextStyles.body,
                              ),
                              TextButton(
                                onPressed: _reload,
                                child: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        );
                      }
                      return _ExploreBody(
                        communities: snap.data ?? const [],
                        onOpen: _openDetail,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        unreadCount: 3,
        onTap: _onNavTap,
        onCreate: _openCreateThread,
      ),
    );
  }
}

class _ExploreBody extends StatelessWidget {
  const _ExploreBody({required this.communities, required this.onOpen});

  final List<Community> communities;
  final ValueChanged<Community> onOpen;

  @override
  Widget build(BuildContext context) {
    final mine = communities
        .where((c) => c.myRole != CommunityRole.guest)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        // Visual saja (pencarian komunitas dikerjakan di FR-01)
        TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Cari komunitas, himpunan, atau UKM...',
            hintStyle: AppTextStyles.helper,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Icon(Icons.tune),
            filled: true,
            fillColor: AppColors.surfaceTint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip('Semua', selected: true),
              _FilterChip('Fakultas'),
              _FilterChip('HIMA'),
              _FilterChip('UKM Kampus'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            const Icon(Icons.stars_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text(
                'Komunitas Saya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              'Lihat Semua (${mine.length})',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (mine.isEmpty)
          const Text(
            'Kamu belum punya komunitas. Tekan + Buat untuk membuat yang pertama.',
            style: AppTextStyles.body,
          )
        else
          LayoutBuilder(
            builder: (context, box) {
              final cardWidth = box.maxWidth * 0.4;
              return SizedBox(
                height: 132,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: mine.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (_, i) => _MyCommunityCard(
                    community: mine[i],
                    width: cardWidth,
                    onTap: () => onOpen(mine[i]),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(this.label, {this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Chip(
        label: Text(label),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.onPrimary : AppColors.textPrimary,
        ),
        backgroundColor: selected ? AppColors.primary : AppColors.chip,
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
    );
  }
}

class _MyCommunityCard extends StatelessWidget {
  const _MyCommunityCard({
    required this.community,
    required this.width,
    required this.onTap,
  });

  final Community community;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommunityAvatar(community: community, radius: 22),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  community.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${community.memberCount} Anggota',
                  style: AppTextStyles.helper,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
