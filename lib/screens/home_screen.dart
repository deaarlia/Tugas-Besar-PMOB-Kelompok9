import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/placeholder_data.dart';
import '../models/thread_sort.dart';
import '../theme/app_theme.dart';
import '../viewmodels/thread_feed_view_model.dart';
import '../widgets/community_filter_sheet.dart';
import '../widgets/report_menu.dart';
import '../widgets/thread_options_sheet.dart';
import 'my_reports_screen.dart';
import 'thread_detail_screen.dart';

/// Beranda (gaya Figma "UnandSpace").
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: context.read<ThreadFeedViewModel>().query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    context.read<ThreadFeedViewModel>().resetFilters();
  }

  String _communityLabel(String? id) {
    if (id == null) return 'Semua Komunitas';
    for (final DemoCommunityOption c in kCommunityOptions) {
      if (c.id == id) return c.name;
    }
    return 'Semua Komunitas';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ThreadFeedViewModel vm = context.watch<ThreadFeedViewModel>();
    final List<DemoPost> threads = vm.visibleThreads;

    // Tap chip urutan yang sedang aktif = kembali ke "Terbaru".
    void toggleSort(ThreadSort s) =>
        vm.selectSort(vm.sort == s ? ThreadSort.newest : s);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('UnandSpace',
                    style: text.titleMedium?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w800)),
                Text('Universitas Andalas',
                    style: text.labelSmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: vm.setQuery,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari topik, mata kuliah, komunitas...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: vm.query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              tooltip: 'Hapus pencarian',
                              onPressed: () {
                                _searchController.clear();
                                vm.setQuery('');
                              },
                            ),
                      filled: true,
                      fillColor: AppColors.surfaceAlt,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.tune, color: AppColors.textSecondary),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppColors.primary, width: 2)),
                  ),
                  child: const Text('Untuk Anda',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text('Diikuti',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                _FilterChipButton(
                  label: ThreadSort.newest.label,
                  active: vm.sort == ThreadSort.newest,
                  onTap: () => vm.selectSort(ThreadSort.newest),
                ),
                _FilterChipButton(
                  label: _communityLabel(vm.selectedCommunityId),
                  active: vm.selectedCommunityId != null,
                  showDropdown: true,
                  onTap: () => showCommunityFilterSheet(
                    context,
                    selectedId: vm.selectedCommunityId,
                    onSelected: vm.selectCommunity,
                  ),
                ),
                _FilterChipButton(
                  label: ThreadSort.popular.label,
                  active: vm.sort == ThreadSort.popular,
                  onTap: () => toggleSort(ThreadSort.popular),
                ),
                _FilterChipButton(
                  label: ThreadSort.unanswered.label,
                  active: vm.sort == ThreadSort.unanswered,
                  onTap: () => toggleSort(ThreadSort.unanswered),
                ),
              ],
            ),
          ),
          if (threads.isEmpty)
            _EmptyResult(onReset: _resetFilters)
          else
            for (final DemoPost p in threads) _PostCard(post: p),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const _Nav(Icons.home, 'Beranda', true),

            // Bungkus menu Komunitas dengan InkWell untuk navigasi ke FR-01
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/community-explore'),
              child: const _Nav(Icons.forum_outlined, 'Komunitas', false),
            ),

            const SizedBox(width: 48), // Ruang kosong untuk FloatingActionButton

            const _Nav(Icons.notifications_none, 'Notifikasi', false),

            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const MyReportsScreen()),
              ),
              child: const _Nav(Icons.person_outline, 'Profil', false),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav(this.icon, this.label, this.active);

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color c = active ? AppColors.primary : AppColors.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: c),
        Text(label, style: TextStyle(fontSize: 11, color: c)),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.showDropdown = false,
  });

  final String label;
  final bool active;
  final bool showDropdown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = active ? Colors.white : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(label, style: TextStyle(fontSize: 13, color: fg)),
              if (showDropdown)
                Icon(Icons.arrow_drop_down, size: 18, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: <Widget>[
          const Icon(Icons.search_off,
              size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          const Text('Tidak ada utas yang cocok',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onReset,
            child: const Text('Reset filter'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final DemoPost post;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ThreadDetailScreen(post: post),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.chipBackground,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(post.author,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(post.tag,
                                style: text.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      Text('${post.sub} • ${post.time}',
                          style: text.bodySmall
                              ?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  onPressed: () {},
                  child: const Text('+ Ikuti', style: TextStyle(fontSize: 12)),
                ),
                IconButton(
                  // Tombol untuk menampilkan menu opsi utas (laporkan, dll).
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Opsi utas',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => showContentOptionsSheet(
                    context,
                    onReport: () =>
                        showReportFlow(context, post.toReportTarget()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.title,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(post.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _VotePill(votes: post.votes),
                const Spacer(),
                const Icon(Icons.chat_bubble_outline,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${post.comments}', style: text.bodySmall),
                const SizedBox(width: 16),
                const Icon(Icons.share_outlined,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VotePill extends StatelessWidget {
  const _VotePill({required this.votes});

  final int votes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.arrow_upward, size: 16),
          const SizedBox(width: 4),
          Text('$votes', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_downward,
              size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}