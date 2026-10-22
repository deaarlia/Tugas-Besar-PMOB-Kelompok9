import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community.dart';
import '../viewmodels/community_list_view_model.dart';
import '../widgets/community_follow_action.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Data dummy utas untuk komunitas (akan diganti REST API di Modul 3)
// ---------------------------------------------------------------------------
class _CommunityThread {
  const _CommunityThread({
    required this.authorName,
    required this.authorBatch,
    required this.department,
    required this.timeAgo,
    required this.body,
    this.hashtags = const [],
    required this.upvotes,
    required this.commentCount,
    this.isPinned = false,
    this.pinnedLabel,
    this.isAnonymous = false,
    this.anonymousTag,
    this.hasImage = false,
    this.imageCaption,
    this.showFollow = true,
  });

  final String authorName;
  final String authorBatch;
  final String department;
  final String timeAgo;
  final String body;
  final List<String> hashtags;
  final int upvotes;
  final int commentCount;
  final bool isPinned;
  final String? pinnedLabel;
  final bool isAnonymous;
  final String? anonymousTag;
  final bool hasImage;
  final String? imageCaption;
  final bool showFollow;
}

// ---------------------------------------------------------------------------
// Screen utama
// ---------------------------------------------------------------------------
class CommunityDetailScreen extends StatefulWidget {
  final Community community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final List<_CommunityThread> _threads;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _threads = _buildDummyThreads();
  }

  List<_CommunityThread> _buildDummyThreads() {
    final communityTag = widget.community.categoryTag;
    final communityName = widget.community.name.toUpperCase();
    return [
      _CommunityThread(
        authorName: 'DISEMATKAN',
        authorBatch: '',
        department: '',
        timeAgo: 'Hari ini',
        body:
            'Pendaftaran Mentoring Pemrograman & Basis Data Semester Genap Telah Dibuka! ðŸš€',
        upvotes: 0,
        commentCount: 32,
        isPinned: true,
        pinnedLabel:
            'DISEMATKAN OLEH PENGURUS $communityName $communityTag â€¢ Hari ini',
        showFollow: false,
      ),
      _CommunityThread(
        authorName: 'Rafly Pratama',
        authorBatch: "FTI'22",
        department: 'Sistem Informasi',
        timeAgo: '2 jam lalu',
        body:
            'Ada yang punya silabus praktikum & materi integrasi Cloud Computing untuk arsitektur microservices semester ini? Khususnya hands-on AWS atau Google Cloud yang dibahas di lab SI.',
        hashtags: ['#PraktikumSI', '#CloudComputing', '#AkademikUnand'],
        upvotes: 42,
        commentCount: 12,
      ),
      _CommunityThread(
        authorName: 'Mahasiswa Anonim',
        authorBatch: '',
        department: 'Departemen SI',
        timeAgo: '3 jam lalu',
        body:
            'Boleh minta tips dan pandangan dari kating mengenai implementasi Enterprise System di semester 5? Lebih prospek fokus ke ERP/SAP atau ke arah IT & Management untuk peluang magang BUMN/swasta?',
        hashtags: ['#EnterpriseSystem', '#TipsKuliah'],
        upvotes: 68,
        commentCount: 24,
        isAnonymous: true,
        anonymousTag: 'Tanya SI',
        showFollow: false,
      ),
      _CommunityThread(
        authorName: 'Annisa Putri',
        authorBatch: "FTI'23",
        department: 'Sistem Informasi',
        timeAgo: '4 jam lalu',
        body:
            'Info Recruitment Kepanitiaan IS FAIR (Information System Fair) 2025 resmi dibuka! Ada 12 divisi mulai dari Acara, Humas, hingga IT & Desain. Daftarkan teman-teman angkatan 23 & 24 dan siapkan CV dan portofolio terbaikmu!',
        hashtags: ['#KepanitiianKampus', '#15Fair2025', '#HMSIUnand'],
        upvotes: 35,
        commentCount: 8,
        hasImage: true,
        imageCaption: '12 Divisi Terbuka â€¢ Deadline 28 Feb',
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityListViewModel>(
      builder: (context, provider, child) {
        final currentCommunity = provider.communities.firstWhere(
          (c) => c.id == widget.community.id,
          orElse: () => widget.community,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8F7),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // â”€â”€ Banner + AppBar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                SliverAppBar(
                  expandedHeight: 190.0,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                        icon: const Icon(Icons.search), onPressed: () {}),
                    IconButton(
                        icon: const Icon(Icons.more_vert), onPressed: () {}),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _BannerImage(community: currentCommunity),
                  ),
                ),

                // â”€â”€ Info komunitas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                SliverToBoxAdapter(
                  child: _CommunityInfoSection(
                    community: currentCommunity,
                    provider: provider,
                  ),
                ),

                // â”€â”€ Tab bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 2.5,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Utas'),
                        Tab(text: 'Tentang'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _ThreadsTab(threads: _threads),
                _AboutTab(community: widget.community),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Banner image
// ---------------------------------------------------------------------------
class _BannerImage extends StatelessWidget {
  const _BannerImage({required this.community});
  final Community community;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (community.bannerUrl != null && community.bannerUrl!.isNotEmpty)
          Image.network(
            community.bannerUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _FallbackBanner(), // ignore: avoid_types_as_parameter_names
          )
        else
          const _FallbackBanner(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), AppColors.primary, Color(0xFF2E7D32)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _MountainPainter(color: Color(0xFF388E3C), peaks: 2),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _MountainPainter(
                  color: Color(0x9943A047), peaks: 3),
            ),
          ),
        ],
      ),
    );
  }
}

class _MountainPainter extends CustomPainter {
  const _MountainPainter({required this.color, required this.peaks});
  final Color color;
  final int peaks;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, size.height);
    final step = size.width / peaks;
    for (int i = 0; i < peaks; i++) {
      path.lineTo(step * i + step / 2, 0);
      path.lineTo(step * (i + 1), size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MountainPainter old) => false;
}

// ---------------------------------------------------------------------------
// Info komunitas
// ---------------------------------------------------------------------------
class _CommunityInfoSection extends StatelessWidget {
  const _CommunityInfoSection(
      {required this.community, required this.provider});
  final Community community;
  final CommunityListViewModel provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(0, -30),
            child: Row(
              children: [_CommunityAvatar(community: community)],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1F1D)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Badge(
                      label: '${community.categoryTag} FTI',
                      bgColor: AppColors.chipBackground,
                      textColor: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    _Badge(
                      label: 'Aktif',
                      bgColor: Color(0xFFE8F5E9),
                      textColor: Color(0xFF00695C),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  community.description,
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.apartment,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Fakultas Teknologi Informasi â€¢ Universitas Andalas',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.groups,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${community.memberCount} Anggota',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1B1F1D),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: community.isFollowing
                                ? AppColors.chipBackground
                                : AppColors.primary,
                            foregroundColor: community.isFollowing
                                ? AppColors.primary
                                : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => handleCommunityFollowTap(
                              context, provider, community),
                          icon: Icon(
                            community.isFollowing
                                ? Icons.check
                                : Icons.group_add_outlined,
                            size: 18,
                          ),
                          label: Text(
                            community.isFollowing ? 'Mengikuti' : 'Bergabung',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _IconActionButton(
                        icon: Icons.notifications_outlined, onTap: () {}),
                    const SizedBox(width: 8),
                    _IconActionButton(icon: Icons.share_outlined, onTap: () {}),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityAvatar extends StatelessWidget {
  const _CommunityAvatar({required this.community});
  final Community community;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
            ],
          ),
          child: CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primary,
            child: Text(
              community.initials,
              style: const TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.verified, size: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
      {required this.label,
      required this.bgColor,
      required this.textColor});
  final String label;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
            color: AppColors.chipBackground,
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab Utas
// ---------------------------------------------------------------------------
class _ThreadsTab extends StatelessWidget {
  const _ThreadsTab({required this.threads});
  final List<_CommunityThread> threads;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: threads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final t = threads[index];
        return t.isPinned
            ? _PinnedThreadCard(thread: t)
            : _ThreadCard(thread: t);
      },
    );
  }
}

class _PinnedThreadCard extends StatelessWidget {
  const _PinnedThreadCard({required this.thread});
  final _CommunityThread thread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.push_pin, size: 13, color: AppColors.primary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  thread.pinnedLabel ?? '',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(thread.body,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 5),
          Text('ðŸ’¬ ${thread.commentCount} balasan',
              style:
                  TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread});
  final _CommunityThread thread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: thread.isAnonymous
                    ? Colors.grey.shade300
                    : AppColors.primaryLight,
                child: thread.isAnonymous
                    ? const Icon(Icons.person_outline,
                        size: 18, color: Colors.grey)
                    : Text(
                        thread.authorName[0].toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(thread.authorName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                        if (thread.authorBatch.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                                color: AppColors.chipBackground,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(thread.authorBatch,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                        if (thread.isAnonymous &&
                            thread.anonymousTag != null) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(thread.anonymousTag!,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                        const Spacer(),
                        Text(thread.timeAgo,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    Text(thread.department,
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (thread.showFollow) _FollowChip(),
              _MoreButton(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            thread.body,
            style: const TextStyle(fontSize: 13, height: 1.45),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          if (thread.hasImage) ...[
            const SizedBox(height: 10),
            _ThreadImagePlaceholder(caption: thread.imageCaption),
          ],
          if (thread.hashtags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: thread.hashtags
                  .map((tag) => Text(tag,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEF0EF)),
          const SizedBox(height: 8),
          Row(
            children: [
              _VoteRow(upvotes: thread.upvotes),
              const Spacer(),
              const Icon(Icons.chat_bubble_outline,
                  size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${thread.commentCount} komentar',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FollowChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(20)),
      child: const Text('+ Ikuti',
          style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _MoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child:
            Icon(Icons.more_horiz, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}

class _VoteRow extends StatelessWidget {
  const _VoteRow({required this.upvotes});
  final int upvotes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {},
          child: const Icon(Icons.arrow_upward,
              size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        Text('$upvotes',
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {},
          child: const Icon(Icons.arrow_downward,
              size: 18, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ThreadImagePlaceholder extends StatelessWidget {
  const _ThreadImagePlaceholder({this.caption});
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined,
                size: 36, color: AppColors.primary.withValues(alpha: 0.4)),
            if (caption != null) ...[
              const SizedBox(height: 6),
              Text(caption!,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab Tentang
// ---------------------------------------------------------------------------
class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.community});
  final Community community;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Informasi Komunitas'),
        const SizedBox(height: 10),
        _buildInfoTile(Icons.calendar_today_outlined, 'Tanggal Dibuat',
            community.createdDate),
        _buildInfoTile(
            Icons.location_on_outlined, 'Lokasi', community.location),
        _buildLinksTile(community.officialLinks),
        const Divider(height: 28),
        const _SectionHeader('Deskripsi'),
        const SizedBox(height: 8),
        Text(community.description,
            style: const TextStyle(
                color: AppColors.textSecondary, height: 1.5, fontSize: 13)),
        const Divider(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionHeader('Tim Moderator Komunitas'),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${community.moderators.length} Moderator Aktif',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...community.moderators.map((mod) => _ModeratorTile(mod: mod)),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksTile(List<String> links) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(8)),
            child:
                const Icon(Icons.link, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tautan & Saluran Resmi',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                ...links.map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Icon(_linkIcon(l),
                              size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(l,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _linkIcon(String url) {
    if (url.startsWith('@')) return Icons.alternate_email;
    if (url.startsWith('#')) return Icons.tag;
    return Icons.language;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
  }
}

class _ModeratorTile extends StatelessWidget {
  const _ModeratorTile({required this.mod});
  final CommunityModerator mod;

  @override
  Widget build(BuildContext context) {
    final isAdmin = mod.badge.toLowerCase() == 'admin';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight,
            child: Text(mod.name[0].toUpperCase(),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mod.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text('${mod.role} â€¢ ${mod.studentBatch}',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAdmin
                  ? AppColors.chipBackground
                  : const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(mod.badge,
                style: TextStyle(
                    fontSize: 11,
                    color: isAdmin
                        ? AppColors.primary
                        : Colors.purple.shade700,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TabBar delegate
// ---------------------------------------------------------------------------
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _TabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}
