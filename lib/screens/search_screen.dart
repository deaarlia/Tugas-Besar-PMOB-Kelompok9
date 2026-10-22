import 'package:flutter/material.dart';

import '../data/thread_repository.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/state_views.dart';
import '../widgets/thread_card.dart';
import 'create_thread_screen.dart';
import 'thread_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.currentUser});

  final UserProfile currentUser;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _suggestedKeywords = [
    'Skripsi',
    'Parkiran',
    'SIA Unand',
    'Magang',
    'Beasiswa',
    'Dosen Pembimbing',
  ];

  final _searchController = TextEditingController();
  final _repository = ThreadRepository.instance;
  final _followedAuthors = <String>{};
  String _query = '';

  List<ThreadPost> get _results {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final matches = _repository.threads.where((thread) {
      return thread.title.toLowerCase().contains(query) ||
          thread.content.toLowerCase().contains(query) ||
          thread.topics.any((topic) => topic.toLowerCase().contains(query)) ||
          thread.displayAuthor.toLowerCase().contains(query);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search([String? value]) {
    final query = (value ?? _searchController.text).trim();
    _searchController.text = query;
    setState(() => _query = query);
    FocusScope.of(context).unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _openThread(ThreadPost thread) {
    final isOwnPost = thread.authorName == widget.currentUser.name;
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ThreadDetailScreen(
          thread: thread,
          currentUser: widget.currentUser,
          isOwnPost: isOwnPost,
          isFollowed: _followedAuthors.contains(thread.authorName),
          onToggleFollow: () {
            setState(() {
              if (!_followedAuthors.add(thread.authorName)) {
                _followedAuthors.remove(thread.authorName);
              }
            });
          },
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
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
    setState(() {});
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
      await _repository.deleteThread(
        threadId: thread.id,
        authorName: widget.currentUser.name,
      );
      if (!mounted) return;
      setState(() {});
      AppSnackbar.showSuccess(context, 'Utas berhasil dihapus.');
    } on ThreadException catch (error) {
      if (mounted) AppSnackbar.showError(context, error.message);
    }
  }

  Future<void> _vote(ThreadPost thread, int vote) async {
    try {
      await _repository.voteThread(
        threadId: thread.id,
        userName: widget.currentUser.name,
        vote: vote,
      );
      if (mounted) setState(() {});
    } on ThreadException catch (error) {
      if (mounted) AppSnackbar.showError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _query;
    final results = _results;
    return Scaffold(
      appBar: AppBar(title: const Text('Pencarian')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildSearchField(),
            Expanded(
              child: query.isEmpty
                  ? _buildIntroduction()
                  : results.isEmpty
                  ? EmptyView(
                      icon: Icons.search_off,
                      message: 'Tidak ada utas yang cocok dengan "$query".',
                    )
                  : _buildResults(results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        height: 42,
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: AppTypography.body),
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value.trim()),
          onSubmitted: _search,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Cari topik, mata kuliah, atau utas...',
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: AppTypography.body,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Hapus pencarian',
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close),
                  ),
            filled: true,
            fillColor: AppColors.chipBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Text(
          'Temukan percakapan',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: AppTypography.sectionTitle,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Cari topik yang sedang dibahas di komunitas Unand.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: AppTypography.label,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Coba cari',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: AppTypography.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestedKeywords
              .map(
                (keyword) => ActionChip(
                  avatar: const Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(keyword),
                  labelStyle: const TextStyle(fontSize: AppTypography.label),
                  onPressed: () => _search(keyword),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResults(List<ThreadPost> threads) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: threads.length,
      itemBuilder: (context, index) {
        final thread = threads[index];
        final isOwnPost = thread.authorName == widget.currentUser.name;
        return ThreadCard(
          thread: thread,
          isOwnPost: isOwnPost,
          isFollowed: _followedAuthors.contains(thread.authorName),
          onToggleFollow: () {
            setState(() {
              if (!_followedAuthors.add(thread.authorName)) {
                _followedAuthors.remove(thread.authorName);
              }
            });
          },
          onOpenDetails: () => _openThread(thread),
          onEdit: isOwnPost ? () => _editThread(thread) : null,
          onDelete: isOwnPost ? () => _deleteThread(thread) : null,
          onVote: isOwnPost ? null : (vote) => _vote(thread, vote),
        );
      },
    );
  }
}
