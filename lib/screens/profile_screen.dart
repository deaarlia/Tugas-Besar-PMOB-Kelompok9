import 'package:flutter/material.dart';

import '../data/thread_repository.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile currentUser;

  const ProfileScreen({super.key, required this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _profileGreen = Color(0xFF007A33);
  static const _profileText = Color(0xFF0B1C30);
  static const _profileMuted = Color(0xFF3F4A3E);
  static const _profileDivider = Color(0xFFE5EEFF);
  final _repository = ThreadRepository.instance;

  int _selectedTab = 0;

  List<ThreadPost> get _myThreads => _repository.threads
      .where(
        (thread) =>
            !thread.isAnonymous && thread.authorName == widget.currentUser.name,
      )
      .toList();

  List<ThreadPost> get _likedThreads =>
      _repository.likedThreadsBy(widget.currentUser.name);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _onNavTap(int index) {
    if (index == 3) return;
    if (index == 0 || index == 1) {
      Navigator.of(context).pushNamedAndRemoveUntil<void>(
        index == 0 ? AppRoutes.home : AppRoutes.communities,
        (_) => false,
      );
      return;
    }
    _showMessage('Halaman ini belum tersedia.');
  }

  Future<void> _openCreateForm() async {
    final created = await Navigator.pushNamed<ThreadPost>(
      context,
      AppRoutes.createThread,
      arguments: widget.currentUser,
    );
    if (!mounted || created == null) return;
    setState(() {});
    _showMessage('Postingan berhasil dibuat!');
  }

  @override
  Widget build(BuildContext context) {
    final myThreads = _myThreads;
    final displayedThreads = _selectedTab == 0 ? myThreads : _likedThreads;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        leadingWidth: 44,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, size: 22),
        ),
        title: const Text('Profil Saya'),
        titleSpacing: 0,
        actions: [
          IconButton(
            tooltip: 'Bagikan profil',
            onPressed: () => _showMessage('Tautan profil berhasil disalin.'),
            icon: const Icon(Icons.ios_share_outlined, size: 20),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 40),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Pengaturan profil',
            onPressed: () => _showMessage('Pengaturan profil belum tersedia.'),
            icon: const Icon(Icons.settings_outlined, size: 20),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 40),
          ),
          const SizedBox(width: 16),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _profileDivider),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            _buildIdentity(),
            const SizedBox(height: 8),
            _buildStats(myThreads),
            const SizedBox(height: 12),
            _buildEditButton(),
            const SizedBox(height: 16),
            _buildTabs(myThreads.length, _likedThreads.length),
            const SizedBox(height: 16),
            if (displayedThreads.isEmpty)
              _buildEmptyState()
            else
              ...displayedThreads.map(_buildThread),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        unreadCount: 3,
        onTap: _onNavTap,
        onCreate: _openCreateForm,
      ),
    );
  }

  Widget _buildIdentity() {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _profileGreen.withValues(alpha: 0.2),
                  blurRadius: 2,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: ColoredBox(
                color: AppColors.avatarBg,
                child: Center(
                  child: Text(
                    widget.currentUser.initials,
                    style: const TextStyle(
                      color: _profileGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.currentUser.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _profileText,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 14,
                      color: _profileMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.currentUser.badge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _profileMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<ThreadPost> myThreads) {
    final replies = myThreads.fold<int>(
      0,
      (total, thread) => total + thread.comments,
    );
    return SizedBox(
      height: 69,
      child: Row(
        children: [
          _statItem('${myThreads.length}', 'UTAS'),
          Container(width: 1, height: 28, color: _profileDivider),
          _statItem('$replies', 'TANGGAPAN'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _profileText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _profileMuted,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: () => _showMessage('Edit profil belum tersedia.'),
        icon: const Icon(Icons.edit_outlined, size: 14),
        label: const Text(
          'Edit Profil',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _profileGreen,
          side: const BorderSide(color: _profileGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildTabs(int threadCount, int likedCount) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            _tab('Utas Saya', '$threadCount', 0),
            _tab('Disukai', '$likedCount', 1),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, String count, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? _profileGreen : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? _profileText : _profileMuted,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE5EEFF)
                      : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    color: selected ? _profileText : _profileMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          _selectedTab == 0
              ? 'Belum ada utas dari ${widget.currentUser.name}.'
              : 'Belum ada utas yang disukai.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _profileMuted, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildThread(ThreadPost thread) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _profileDivider, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!thread.isAnonymous && thread.authorBadge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    thread.authorBadge,
                    style: const TextStyle(
                      color: _profileMuted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              if (!thread.isAnonymous && thread.authorBadge.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: _profileMuted)),
                const SizedBox(width: 8),
              ],
              Text(
                thread.timeLabel,
                style: const TextStyle(color: _profileMuted, fontSize: 12),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Opsi utas',
                onPressed: () => _showMessage('Tidak ada opsi tambahan.'),
                icon: const Icon(Icons.more_horiz, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            thread.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _profileText,
              fontSize: 16,
              height: 1.22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            thread.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _profileMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _threadAction(Icons.arrow_upward, '${thread.upvotes}'),
              const SizedBox(width: 12),
              _threadAction(Icons.chat_bubble_outline, '${thread.comments}'),
              const Spacer(),
              IconButton(
                tooltip: 'Bagikan utas',
                onPressed: () => _showMessage('Tautan utas berhasil disalin.'),
                icon: const Icon(Icons.ios_share_outlined, size: 18),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _threadAction(IconData icon, String value) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        border: Border.all(color: _profileDivider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _profileGreen),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: _profileMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
