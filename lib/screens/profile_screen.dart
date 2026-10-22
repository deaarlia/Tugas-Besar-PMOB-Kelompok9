import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/placeholder_data.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../viewmodels/profile_view_model.dart';
import 'edit_profile_screen.dart';
import 'my_reports_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Utas demo milik pengguna ini (subset dari demoPosts).
  static final List<DemoPost> _myThreads = demoPosts
      .where((p) => p.author == 'Fajar Nugraha')
      .toList();

  // Utas yang disukai (demo — ambil beberapa post acak).
  static final List<DemoPost> _likedThreads = demoPosts
      .where((p) => p.author != 'Fajar Nugraha')
      .take(3)
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileViewModel>().profile;

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          _ProfileAppBar(profile: profile),
          _ProfileHeader(profile: profile),
          _ProfileStats(profile: profile),
          _ProfileActions(profile: profile),
          _ProfileTabBar(controller: _tabController,
              myCount: _myThreads.length,
              likedCount: _likedThreads.length),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ThreadList(threads: _myThreads, emptyMsg: 'Belum ada utas'),
            _ThreadList(threads: _likedThreads, emptyMsg: 'Belum ada utas yang disukai'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── SliverAppBar ────────────────────────────────────

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      title: Text(profile.username,
          style: const TextStyle(
              color: Color(0xFF1B1F1D),
              fontWeight: FontWeight.w700,
              fontSize: 17)),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Color(0xFF1B1F1D)),
          tooltip: 'Bagikan profil',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Color(0xFF1B1F1D)),
          tooltip: 'Opsi',
          onPressed: () {},
        ),
      ],
    );
  }
}

// ──────────────────────── Header (foto + nama + bio) ─────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primaryLight,
                      child: profile.avatarAsset != null
                          ? null
                          : const Icon(Icons.person,
                              size: 36, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.fullName,
                              style: text.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (profile.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('AKTIF',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                        ],
                      ),
                      Text('@${profile.username}',
                          style: text.bodySmall?.copyWith(
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Jurusan & Angkatan
            Row(
              children: [
                const Icon(Icons.school_outlined,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(profile.yearLabel,
                    style: text.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            // Bio
            Text(profile.bio, style: text.bodyMedium),
            const SizedBox(height: 6),
            // Lokasi
            if (profile.location.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(profile.location,
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            const SizedBox(height: 4),
            // LinkedIn
            if (profile.linkedinUrl.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.link, size: 15, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(profile.linkedinUrl,
                      style: text.bodySmall?.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── Statistik follower / following ──────────────────────

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _StatItem(
                count: profile.followers, label: 'PENGIKUT', text: text),
            const SizedBox(width: 24),
            _StatItem(
                count: profile.following, label: 'MENGIKUTI', text: text),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(
      {required this.count, required this.label, required this.text});
  final int count;
  final String label;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$count',
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(width: 6),
        Text(label,
            style: text.labelSmall
                ?.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
      ],
    );
  }
}

// ───────────────────────────── Tombol aksi ───────────────────────────────────

class _ProfileActions extends StatelessWidget {
  const _ProfileActions({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        child: Column(
          children: [
            // Edit Profil
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: const Size(0, 44),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profil',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () async {
                  final vm = context.read<ProfileViewModel>();
                  final updated = await Navigator.of(context).push<UserProfile>(
                    MaterialPageRoute(
                      builder: (_) =>
                          ChangeNotifierProvider.value(
                            value: vm,
                            child: EditProfileScreen(initial: vm.profile),
                          ),
                    ),
                  );
                  if (updated != null) {
                    vm.saveProfile(updated);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            // Laporan Saya
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.divider),
                  foregroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: const Size(0, 44),
                ),
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: const Text('Laporan Saya',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const MyReportsScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────── TabBar ─────────────────────────────────────────

class _ProfileTabBar extends StatelessWidget {
  const _ProfileTabBar({
    required this.controller,
    required this.myCount,
    required this.likedCount,
  });
  final TabController controller;
  final int myCount;
  final int likedCount;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: controller,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Utas Saya  $myCount'),
            Tab(text: 'Disukai  $likedCount'),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

// ──────────────────────── Daftar utas di dalam tab ───────────────────────────

class _ThreadList extends StatelessWidget {
  const _ThreadList({required this.threads, required this.emptyMsg});
  final List<DemoPost> threads;
  final String emptyMsg;

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return Center(
        child: Text(emptyMsg,
            style: const TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: threads.length,
      itemBuilder: (_, i) => _ProfileThreadCard(post: threads[i]),
    );
  }
}

class _ProfileThreadCard extends StatelessWidget {
  const _ProfileThreadCard({required this.post});
  final DemoPost post;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag + waktu
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4)),
                child: Text(post.tag,
                    style: text.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Text('• ${post.time}',
                  style: text.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              const Icon(Icons.more_horiz,
                  size: 20, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 6),
          Text(post.title,
              style:
                  text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          // Bawah: vote + komentar + bookmark + share
          Row(
            children: [
              // Vote pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_upward, size: 15),
                    const SizedBox(width: 4),
                    Text('${post.votes}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_downward,
                        size: 15, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chat_bubble_outline,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${post.comments}',
                  style: text.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              const Icon(Icons.bookmark_outline,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              const Icon(Icons.share_outlined,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
