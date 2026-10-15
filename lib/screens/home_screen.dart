import 'package:flutter/material.dart';

import '../data/thread_repository.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import 'thread_detail_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/state_views.dart';
import '../widgets/thread_card.dart';

enum ViewStatus { loading, success, error }

enum FeedFilter { terbaru, semuaKomunitas, terpopuler, belumTerjawab }

class HomeScreen extends StatefulWidget {
  // Data pengguna yang sedang login
  final UserProfile currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = ThreadRepository.instance;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  ViewStatus _status = ViewStatus.loading;
  List<ThreadPost> _threads = [];
  String _errorMessage = '';

  int _tabIndex = 0; // 0 = Untuk Anda, 1 = Diikuti
  FeedFilter _filter = FeedFilter.terbaru;
  String _query = '';
  final Set<String> _followed = {};

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadThreads() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      final threads = await _repository.fetchThreads();
      if (!mounted) return;
      setState(() {
        _threads = List.of(threads);
        _status = ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  Future<void> _openCreateForm() async {
    final newThread = await Navigator.pushNamed<ThreadPost>(
      context,
      AppRoutes.createThread,
      arguments: widget.currentUser,
    );

    if (!mounted || newThread == null) return;

    setState(() {
      _threads = _repository.threads;
      _tabIndex = 0;
      _filter = FeedFilter.terbaru;
      _query = '';
      _searchController.clear();
    });

    // Gulir ke atas agar utas baru langsung terlihat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });

    AppSnackbar.showSuccess(context, 'Postingan berhasil dibuat!');
  }

  void _openThreadDetails(ThreadPost thread) {
    final isOwnPost = thread.authorName == widget.currentUser.name;
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ThreadDetailScreen(
          thread: thread,
          isOwnPost: isOwnPost,
          isFollowed: _followed.contains(thread.authorName),
          onToggleFollow: () => _toggleFollow(thread.authorName),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 0) return; // sudah di Beranda
    _showSoon('Halaman ini belum tersedia.');
  }

  void _showSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _toggleFollow(String authorName) {
    setState(() {
      if (!_followed.remove(authorName)) _followed.add(authorName);
    });
  }

  List<ThreadPost> get _visibleThreads {
    var list = List.of(_threads);

    if (_tabIndex == 1) {
      list = list
          .where((t) => !t.isAnonymous && _followed.contains(t.authorName))
          .toList();
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                t.content.toLowerCase().contains(q) ||
                t.topics.any((x) => x.toLowerCase().contains(q)),
          )
          .toList();
    }

    switch (_filter) {
      case FeedFilter.terpopuler:
        list.sort((a, b) => b.upvotes.compareTo(a.upvotes));
      case FeedFilter.belumTerjawab:
        list = list.where((t) => t.comments == 0).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case FeedFilter.terbaru:
      case FeedFilter.semuaKomunitas:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  String get _emptyMessage {
    if (_query.isNotEmpty) return 'Tidak ada utas yang cocok dengan "$_query".';
    if (_tabIndex == 1) return 'Belum ada utas dari akun yang kamu ikuti.';
    if (_filter == FeedFilter.belumTerjawab) {
      return 'Semua utas sudah ada tanggapan.';
    }
    return 'Belum ada utas. Jadilah yang pertama!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearch(),
            _buildTabs(),
            _buildFilterChips(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        unreadCount: 3,
        onTap: _onNavTap,
        onCreate: _openCreateForm,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.avatarBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          const Text(
            'UnandSpace',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          // Avatar juga membuka menu simulasi error (khusus untuk demo)
          PopupMenuButton<String>(
            onSelected: (_) => setState(
              () => _repository.simulateError = !_repository.simulateError,
            ),
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'error',
                checked: _repository.simulateError,
                child: const Text('Simulasikan error kirim'),
              ),
            ],
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.avatarBg,
              child: Text(
                widget.currentUser.initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 13),
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: 'Cari topik, mata kuliah, komunitas...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.chipBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.outlined(
            tooltip: 'Filter',
            onPressed: () => _showSoon('Filter lanjutan belum tersedia.'),
            icon: const Icon(Icons.tune, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.chipBg,
              foregroundColor: AppColors.textDark,
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    Widget tab(int index, String label) {
      final selected = _tabIndex == index;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _tabIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [tab(0, 'Untuk Anda'), tab(1, 'Diikuti')]),
    );
  }

  Widget _buildFilterChips() {
    const labels = {
      FeedFilter.terbaru: 'Terbaru',
      FeedFilter.semuaKomunitas: 'Semua Komunitas',
      FeedFilter.terpopuler: 'Terpopuler',
      FeedFilter.belumTerjawab: 'Belum Terjawab',
    };
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: labels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = FeedFilter.values[index];
          final selected = _filter == filter;
          return ChoiceChip(
            label: Text(labels[filter]!),
            selected: selected,
            showCheckmark: false,
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            shape: const StadiumBorder(),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
            onSelected: (_) => setState(() => _filter = filter),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(message: 'Memuat utas...'),
      ViewStatus.error => ErrorView(
        message: _errorMessage,
        onRetry: _loadThreads,
      ),
      ViewStatus.success => _buildFeed(),
    };
  }

  Widget _buildFeed() {
    final threads = _visibleThreads;
    if (threads.isEmpty) {
      return EmptyView(icon: Icons.forum_outlined, message: _emptyMessage);
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: threads.length,
      itemBuilder: (context, index) {
        final t = threads[index];
        return ThreadCard(
          thread: t,
          isOwnPost: t.authorName == widget.currentUser.name,
          isFollowed: _followed.contains(t.authorName),
          onToggleFollow: () => _toggleFollow(t.authorName),
          onOpenDetails: () => _openThreadDetails(t),
        );
      },
    );
  }
}
