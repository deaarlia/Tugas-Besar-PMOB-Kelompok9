import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/placeholder_data.dart';
import '../models/notification_item.dart';
import '../repositories/community_repository.dart';
import '../screens/community_detail_screen.dart';
import '../screens/my_reports_screen.dart';
import '../screens/thread_detail_screen.dart';
import '../viewmodels/notification_view_model.dart';
import '../theme/app_theme.dart';

/// Halaman Notifikasi sesuai desain UnandConnect.
/// Menggunakan NotificationViewModel dari global provider tree (main.dart)
/// agar badge di Beranda dan status baca/belum-baca tetap sinkron.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NotificationBody();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body utama (sudah punya Provider di atas)
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationBody extends StatefulWidget {
  const _NotificationBody();

  @override
  State<_NotificationBody> createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<_NotificationBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Navigasi ke halaman yang dituju notifikasi, lalu tandai dibaca.
  Future<void> _handleNotifTap(
      BuildContext context, NotificationViewModel vm, String id) async {
    // 1. Tandai dibaca lebih dulu
    vm.markAsRead(id);

    final item = vm.getById(id);
    if (item == null) return;

    switch (item.destination) {
      case NotifDestination.thread:
        final destId = item.destinationId;
        if (destId == null) return;
        final post = demoPosts.firstWhere(
          (p) => p.id == destId,
          orElse: () => demoPosts.first,
        );
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ThreadDetailScreen(post: post)),
          );
        }
        break;

      case NotifDestination.community:
        final destId = item.destinationId;
        if (destId == null) return;
        // Gunakan CommunityRepository dari provider tree
        final repo = context.read<CommunityRepository>();
        final community = await repo.getCommunityById(destId);
        if (community != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommunityDetailScreen(community: community),
            ),
          );
        }
        break;

      case NotifDestination.myReports:
        // MyReportsScreen menggunakan MyReportsViewModel dari global provider tree
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyReportsScreen()),
          );
        }
        break;

      case NotifDestination.communityExplore:
        if (context.mounted) {
          Navigator.pushNamed(context, '/community-explore');
        }
        break;

      case NotifDestination.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();
    final unread = vm.unreadCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(unread, vm),
      body: Column(
        children: [
          // ── Filter tabs (scrollable agar tidak overflow) ──────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TabChip(
                    label: 'Semua',
                    active: _activeTab == 0,
                    onTap: () {
                      _tabController.animateTo(0);
                      setState(() => _activeTab = 0);
                    },
                  ),
                  const SizedBox(width: 8),
                  _TabChip(
                    label: 'Balasan & Disebut',
                    active: _activeTab == 1,
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() => _activeTab = 1);
                    },
                  ),
                  const SizedBox(width: 8),
                  _TabChip(
                    label: 'Aktivitas Komunitas',
                    active: _activeTab == 2,
                    onTap: () {
                      _tabController.animateTo(2);
                      setState(() => _activeTab = 2);
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // ── Daftar notifikasi ──────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: Semua
                _NotifList(
                  todayItems: vm.todayItems,
                  previousItems: vm.previousItems,
                  allRead: vm.allRead,
                  todayCount: unread,
                  onTap: (id) => _handleNotifTap(context, vm, id),
                ),
                // Tab 1: Balasan & Disebut
                _NotifList(
                  todayItems: vm.todayItems
                      .where((n) =>
                          n.type == NotifType.reply ||
                          n.type == NotifType.mention)
                      .toList(),
                  previousItems: vm.previousItems
                      .where((n) =>
                          n.type == NotifType.reply ||
                          n.type == NotifType.mention)
                      .toList(),
                  allRead: vm.allRead,
                  todayCount: unread,
                  onTap: (id) => _handleNotifTap(context, vm, id),
                ),
                // Tab 2: Aktivitas Komunitas
                _NotifList(
                  todayItems: vm.todayItems
                      .where((n) =>
                          n.type == NotifType.announcement ||
                          n.type == NotifType.event ||
                          n.type == NotifType.moderation)
                      .toList(),
                  previousItems: vm.previousItems
                      .where((n) =>
                          n.type == NotifType.announcement ||
                          n.type == NotifType.event ||
                          n.type == NotifType.moderation)
                      .toList(),
                  allRead: vm.allRead,
                  todayCount: unread,
                  onTap: (id) => _handleNotifTap(context, vm, id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int unread, NotificationViewModel vm) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1F1D)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.school, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UnandConnect',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15),
              ),
              const Text(
                'Universitas Andalas',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child:
                const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Judul "Notifikasi"
                const Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1F1D),
                  ),
                ),
                const SizedBox(width: 8),
                if (unread > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unread baru',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                const Spacer(),
                // Tandai semua dibaca (Flexible agar tidak overflow)
                if (!vm.allRead)
                  GestureDetector(
                    onTap: vm.markAllAsRead,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.done_all,
                            size: 13, color: AppColors.primary),
                        SizedBox(width: 3),
                        Text(
                          'Tandai dibaca',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daftar notifikasi dengan seksi Hari Ini & Sebelumnya
// ─────────────────────────────────────────────────────────────────────────────
class _NotifList extends StatelessWidget {
  const _NotifList({
    required this.todayItems,
    required this.previousItems,
    required this.allRead,
    required this.todayCount,
    required this.onTap,
  });

  final List<NotificationItem> todayItems;
  final List<NotificationItem> previousItems;
  final bool allRead;
  final int todayCount;
  final void Function(String id) onTap;

  @override
  Widget build(BuildContext context) {
    final bool empty = todayItems.isEmpty && previousItems.isEmpty;

    if (empty) {
      return _EmptyNotif();
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Seksi HARI INI ────────────────────────────────────────────
        if (todayItems.isNotEmpty) ...[
          _SectionHeader(
            label: 'HARI INI',
            badge: todayCount > 0 ? '$todayCount baru' : null,
          ),
          ...todayItems
              .map((n) => _NotifTile(item: n, onTap: onTap)),
        ],

        // ── Seksi SEBELUMNYA ──────────────────────────────────────────
        if (previousItems.isNotEmpty) ...[
          _SectionHeader(label: 'SEBELUMNYA'),
          ...previousItems
              .map((n) => _NotifTile(item: n, onTap: onTap)),
        ],

        // ── State akhir: semua sudah ditinjau ─────────────────────────
        if (allRead) _AllReadFooter(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header seksi (HARI INI / SEBELUMNYA)
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.badge});
  final String label;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────────
// Satu baris notifikasi
// ────────────────────────────────────────────────────────────────────────────────
class _NotifTile extends StatefulWidget {
  const _NotifTile({required this.item, required this.onTap});
  final NotificationItem item;
  final void Function(String) onTap;

  @override
  State<_NotifTile> createState() => _NotifTileState();
}

class _NotifTileState extends State<_NotifTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;
  late Animation<double> _dotFade;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: widget.item.isRead ? 0.0 : 1.0,
    );
    _dotFade = CurvedAnimation(parent: _dotController, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(_NotifTile old) {
    super.didUpdateWidget(old);
    // Saat isRead berubah dari false -> true, animasikan dot menghilang
    if (!old.item.isRead && widget.item.isRead) {
      _dotController.reverse();
    }
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      color: item.isRead
          ? Colors.white
          : AppColors.primaryLight.withValues(alpha: 0.35),
      child: InkWell(
        onTap: () => widget.onTap(item.id),
        splashColor: AppColors.primaryLight.withValues(alpha: 0.4),
        highlightColor: AppColors.primaryLight.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar / ikon ────────────────────────────────────────────
              _NotifAvatar(type: item.type),
              const SizedBox(width: 12),

              // ── Konten ────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul: aktor + aksi
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF1B1F1D),
                            height: 1.4,
                            fontWeight: item.isRead
                                ? FontWeight.w400
                                : FontWeight.w500),
                        children: [
                          TextSpan(
                            text: item.actorName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: ' ${item.message}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Preview
                    Text(
                      item.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    // Waktu + label "Ketuk untuk lihat" jika ada tujuan
                    Row(
                      children: [
                        Text(
                          item.timeAgo,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                        if (item.destination != NotifDestination.none) ...[
                          const SizedBox(width: 6),
                          const Text('·',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                          const SizedBox(width: 6),
                          Text(
                            _destinationLabel(item.destination),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Dot belum dibaca (dengan animasi fade) ──────────────────
              FadeTransition(
                opacity: _dotFade,
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _destinationLabel(NotifDestination dest) {
    switch (dest) {
      case NotifDestination.thread:
        return 'Lihat utas';
      case NotifDestination.community:
        return 'Lihat komunitas';
      case NotifDestination.myReports:
        return 'Lihat laporan';
      case NotifDestination.communityExplore:
        return 'Jelajahi komunitas';
      case NotifDestination.none:
        return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar/ikon sesuai tipe notifikasi
// ─────────────────────────────────────────────────────────────────────────────
class _NotifAvatar extends StatelessWidget {
  const _NotifAvatar({required this.type});
  final NotifType type;

  @override
  Widget build(BuildContext context) {
    final cfg = _config(type);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: cfg.bg,
        shape: BoxShape.circle,
      ),
      child: Icon(cfg.icon, color: cfg.fg, size: 22),
    );
  }

  _AvatarConfig _config(NotifType type) {
    switch (type) {
      case NotifType.moderation:
        return _AvatarConfig(
          icon: Icons.shield_outlined,
          bg: AppColors.chipBackground,
          fg: AppColors.primary,
        );
      case NotifType.reply:
        return _AvatarConfig(
          icon: Icons.person,
          bg: const Color(0xFFE8EAF6),
          fg: const Color(0xFF3949AB),
        );
      case NotifType.like:
        return _AvatarConfig(
          icon: Icons.arrow_upward,
          bg: const Color(0xFFFFF8E1),
          fg: const Color(0xFFF9A825),
        );
      case NotifType.announcement:
        return _AvatarConfig(
          icon: Icons.campaign_outlined,
          bg: AppColors.chipBackground,
          fg: AppColors.primary,
        );
      case NotifType.verification:
        return _AvatarConfig(
          icon: Icons.account_balance_outlined,
          bg: const Color(0xFFE8F5E9),
          fg: const Color(0xFF2E7D32),
        );
      case NotifType.mention:
        return _AvatarConfig(
          icon: Icons.alternate_email,
          bg: const Color(0xFFF3E5F5),
          fg: const Color(0xFF7B1FA2),
        );
      case NotifType.event:
        return _AvatarConfig(
          icon: Icons.event_outlined,
          bg: AppColors.chipBackground,
          fg: AppColors.primary,
        );
    }
  }
}

class _AvatarConfig {
  const _AvatarConfig(
      {required this.icon, required this.bg, required this.fg});
  final IconData icon;
  final Color bg;
  final Color fg;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab chip (Semua / Balasan & Disebut / Aktivitas Komunitas)
// ─────────────────────────────────────────────────────────────────────────────
class _TabChip extends StatelessWidget {
  const _TabChip(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State kosong (tidak ada notifikasi di tab ini)
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyNotif extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.notifications_none,
                size: 52, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'Tidak ada notifikasi',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            SizedBox(height: 6),
            Text(
              'Notifikasi baru akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer "semua notifikasi telah ditinjau"
// ─────────────────────────────────────────────────────────────────────────────
class _AllReadFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: const [
          Icon(Icons.check, size: 28, color: AppColors.textSecondary),
          SizedBox(height: 8),
          Text(
            'Semua notifikasi telah ditinjau',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF1B1F1D)),
          ),
          SizedBox(height: 4),
          Text(
            'Kabar akademik dan komunitas Universitas\nAndalas sudah terupdate.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
