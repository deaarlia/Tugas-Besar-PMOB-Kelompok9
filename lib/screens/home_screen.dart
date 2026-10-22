import 'package:flutter/material.dart';

import '../data/thread_repository.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../viewmodels/home_view_model.dart';
import 'thread_detail_screen.dart';
import 'create_thread_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/state_views.dart';
import '../widgets/thread_card.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  // Data pengguna yang sedang login
  final UserProfile currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel = HomeViewModel();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel.loadThreads();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openCreateForm() async {
    final newThread = await Navigator.pushNamed<ThreadPost>(
      context,
      AppRoutes.createThread,
      arguments: widget.currentUser,
    );

    if (!mounted || newThread == null) return;

    _viewModel.onThreadCreated();

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
          currentUser: widget.currentUser,
          isOwnPost: isOwnPost,
          isFollowed: _viewModel.followed.contains(thread.authorName),
          onToggleFollow: () => _viewModel.toggleFollow(thread.authorName),
        ),
      ),
    ).then((_) {
      if (mounted) _viewModel.refreshThreads();
    });
  }

  Future<void> _editThread(ThreadPost thread) async {
    final updated = await Navigator.push<ThreadPost>(
      context,
      MaterialPageRoute<ThreadPost>(
        builder: (_) => CreateThreadScreen(
          author: widget.currentUser,
          editingThread: thread,
        ),
      ),
    );
    if (!mounted || updated == null) return;
    _viewModel.refreshThreads();
    AppSnackbar.showSuccess(context, 'Utas berhasil diperbarui.');
  }

  Future<void> _deleteThread(ThreadPost thread) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus utas?'),
        content: const Text(
          'Utas akan disembunyikan dari komunitas. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || shouldDelete != true) return;
    try {
      await ThreadRepository.instance.deleteThread(
        threadId: thread.id,
        authorName: widget.currentUser.name,
      );
      if (!mounted) return;
      _viewModel.refreshThreads();
      AppSnackbar.showSuccess(context, 'Utas berhasil dihapus.');
    } on ThreadException catch (error) {
      if (mounted) AppSnackbar.showError(context, error.message);
    }
  }

  void _onNavTap(int index) {
    if (index == 0) return; // sudah di Beranda
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.communities);
      return;
    }
    if (index == 3) {
      Navigator.pushNamed(
        context,
        AppRoutes.profile,
        arguments: widget.currentUser,
      );
      return;
    }
    _showSoon('Halaman ini belum tersedia.');
  }

  void _showSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _openSearch() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SearchScreen(currentUser: widget.currentUser),
      ),
    );
    if (mounted) _viewModel.refreshThreads();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
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
              fontSize: AppTypography.pageTitle,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: (_) => _viewModel.toggleSimulateError(),
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'error',
                checked: _viewModel.simulateError,
                child: const Text('Simulasikan error kirim'),
              ),
            ],
            tooltip: 'Menu lainnya',
            child: const Icon(Icons.more_vert, color: AppColors.textMuted),
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
            child: SizedBox(
              height: 40,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _openSearch,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.primary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Cari topik, mata kuliah, komunitas...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: AppTypography.body,
                          ),
                        ),
                      ),
                    ],
                  ),
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
      final selected = _viewModel.tabIndex == index;
      return Expanded(
        child: InkWell(
          onTap: () => _viewModel.selectTab(index),
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
                fontSize: AppTypography.body,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          final selected = _viewModel.filter == filter;
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
              fontSize: AppTypography.label,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
            onSelected: (_) => _viewModel.selectFilter(filter),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return switch (_viewModel.status) {
      ViewStatus.loading => const LoadingView(message: 'Memuat utas...'),
      ViewStatus.error => ErrorView(
        message: _viewModel.errorMessage,
        onRetry: _viewModel.loadThreads,
      ),
      ViewStatus.success => _buildFeed(),
    };
  }

  Widget _buildFeed() {
    final threads = _viewModel.visibleThreads;
    if (threads.isEmpty) {
      return EmptyView(
        icon: Icons.forum_outlined,
        message: _viewModel.emptyMessage,
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: threads.length + (_viewModel.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == threads.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: _viewModel.isLoadingMore
                  ? const CircularProgressIndicator()
                  : _viewModel.loadMoreError != null
                  ? Column(
                      children: [
                        Text(
                          _viewModel.loadMoreError!,
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: _viewModel.loadMore,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    )
                  : TextButton(
                      onPressed: _viewModel.loadMore,
                      child: const Text('Muat utas lainnya'),
                    ),
            ),
          );
        }
        final t = threads[index];
        final isOwnPost = t.authorName == widget.currentUser.name;
        return ThreadCard(
          thread: t,
          isOwnPost: isOwnPost,
          isFollowed: _viewModel.followed.contains(t.authorName),
          onToggleFollow: () => _viewModel.toggleFollow(t.authorName),
          onOpenDetails: () => _openThreadDetails(t),
          onEdit: isOwnPost ? () => _editThread(t) : null,
          onDelete: isOwnPost ? () => _deleteThread(t) : null,
          onVote: isOwnPost
              ? null
              : (vote) async {
                  final callbackContext = context;
                  final error = await _viewModel.voteThread(
                    threadId: t.id,
                    userName: widget.currentUser.name,
                    vote: vote,
                  );
                  if (!callbackContext.mounted) return;
                  if (error != null) {
                    AppSnackbar.showError(callbackContext, error);
                  }
                },
        );
      },
    );
  }
}
