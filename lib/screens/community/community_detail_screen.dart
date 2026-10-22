// lib/screens/community/community_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_pmob/models/community.dart';
import 'package:tugas_pmob/models/thread_post.dart';
import 'package:tugas_pmob/repositories/community_repository.dart';
import 'package:tugas_pmob/screens/community/edit_community_screen.dart';
import 'package:tugas_pmob/screens/community/manage_moderators_screen.dart';
import 'package:tugas_pmob/screens/community/report_queue_screen.dart';
import 'package:tugas_pmob/screens/community/rules_edit_screen.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/theme/app_spacing.dart';
import 'package:tugas_pmob/theme/app_text_styles.dart';
import 'package:tugas_pmob/utils/image_source.dart';
import 'package:tugas_pmob/viewmodels/threads_provider.dart';
import 'package:tugas_pmob/widgets/community/category_badge.dart';
import 'package:tugas_pmob/widgets/community/community_avatar.dart';
import 'package:tugas_pmob/widgets/community/feedback_dialog.dart';
import 'package:tugas_pmob/widgets/community/thread_widgets.dart';
import 'package:unand_space/models/community.dart';
import 'package:unand_space/repositories/community_repository.dart';
import 'package:unand_space/screens/community/edit_community_screen.dart';
import 'package:unand_space/screens/community/manage_moderators_screen.dart';
import 'package:unand_space/screens/community/rules_edit_screen.dart';
import 'package:unand_space/theme/app_colors.dart';
import 'package:unand_space/theme/app_spacing.dart';
import 'package:unand_space/theme/app_text_styles.dart';
import 'package:unand_space/utils/image_source.dart';
import 'package:unand_space/widgets/community/category_badge.dart';
import 'package:unand_space/widgets/community/community_avatar.dart';


enum _MenuAction { reports, edit, rules, moderators }

class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen({super.key, required this.community});

  final Community community;

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  late Community _community = widget.community;
  late final TabController _tabs = TabController(length: 2, vsync: this);
  late Future<List<Moderator>> _moderators;
  late final ThreadsProvider _threads;

  bool get _canModerate =>
      _community.myRole == CommunityRole.creator ||
      _community.myRole == CommunityRole.moderator;

  @override
  void initState() {
    super.initState();
    final repo = context.read<CommunityRepository>();
    _moderators = repo.listModerators(widget.community.id);
    _threads = ThreadsProvider(
      repository: repo,
      communityId: widget.community.id,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _threads.dispose();
    super.dispose();
  }

  Future<void> _openEdit() async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<CommunityFormResult>(
      MaterialPageRoute(
        builder: (_) => EditCommunityScreen(community: _community),
      ),
    );
    if (!mounted || result == null) return;
    if (result.deleted) {
      navigator.pop();
    } else if (result.community != null) {
      setState(() => _community = result.community!);
    }
  }

  Future<void> _openRules() async {
    final result = await Navigator.of(context).push<Community>(
      MaterialPageRoute(builder: (_) => RulesEditScreen(community: _community)),
    );
    if (!mounted || result == null) return;
    setState(() => _community = result);
  }

  Future<void> _openModerators() async {
    final repo = context.read<CommunityRepository>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManageModeratorsScreen(community: _community),
      ),
    );
    if (!mounted) return;
    setState(() => _moderators = repo.listModerators(_community.id));
  }

  Future<void> _openReports() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportQueueScreen(community: _community),
      ),
    );
    if (!mounted) return;
    _threads.load(); // utas yang dihapus lewat laporan harus hilang dari daftar
  }

  PopupMenuItem<_MenuAction> _item(
    _MenuAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<_MenuAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.md),
          Text(label),
        ],
      ),
    );
  }

  Widget? _menu() {
    if (!_canModerate) return null;
    final isCreator = _community.myRole == CommunityRole.creator;
    return PopupMenuButton<_MenuAction>(
      icon: const Icon(Icons.more_vert),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      onSelected: (a) {
        switch (a) {
          case _MenuAction.reports:
            _openReports();
          case _MenuAction.edit:
            _openEdit();
          case _MenuAction.rules:
            _openRules();
          case _MenuAction.moderators:
            _openModerators();
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<_MenuAction>>[
        _item(_MenuAction.reports, Icons.flag_outlined, 'Antrean Laporan'),
        if (isCreator) ...[
          const PopupMenuDivider(),
          _item(_MenuAction.edit, Icons.edit_outlined, 'Ubah Komunitas'),
          _item(_MenuAction.rules, Icons.gavel_outlined, 'Atur Aturan'),
          _item(
            _MenuAction.moderators,
            Icons.admin_panel_settings_outlined,
            'Kelola Moderator',
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = _menu();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Komunitas', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          menu ?? const SizedBox.shrink(),
          ?menu,
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DetailHeader(community: _community),
                  TabBar(
                    controller: _tabs,
                    tabs: const [
                      Tab(text: 'Utas'),
                      Tab(text: 'Tentang'),
                    ],
                    labelColor: AppColors.primary,
                    indicatorColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    dividerColor: AppColors.outline,
                  ),
                  ListenableBuilder(
                    listenable: _tabs,
                    builder: (_, _) => _tabs.index == 0
                        ? ChangeNotifierProvider.value(
                            value: _threads,
                            child: _ThreadsTab(
                              communityName: _community.name,
                              canModerate: _canModerate,
                            ),
                          )

                        ? const _ThreadsEmptyState()

                        : _AboutTab(
                            community: _community,
                            moderators: _moderators,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.community});

  final Community community;

  @override
  Widget build(BuildContext context) {
    final cover = imageProviderFor(community.coverUrl);
    const half = AppSpacing.iconAvatar / 2;
    final joined = community.myRole != CommunityRole.guest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: half),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: AppSpacing.coverAspectRatio,
                child: cover != null
                    ? Image(image: cover, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.chip,
                        child: const Icon(
                          Icons.groups,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              Positioned(
                left: AppSpacing.lg,
                bottom: -half,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: CommunityAvatar(
                    community: community,
                    radius: half - 3,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      community.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  CategoryBadge(label: community.category.label),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(community.description, style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${community.memberCount} Anggota',
                    style: AppTextStyles.fieldLabel,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Visual saja (ikuti, notifikasi, dan bagikan bukan bagian FR-08)
              Row(
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            joined ? Icons.check : Icons.person_add_alt,
                            size: 18,
                          ),
                          label: Text(
                            joined ? 'Mengikuti' : 'Bergabung',
                            style: AppTextStyles.button,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _OutlinedIconBox(
                    icon: Icons.notifications_none,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _OutlinedIconBox(icon: Icons.share_outlined, onTap: () {}),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutlinedIconBox extends StatelessWidget {
  const _OutlinedIconBox({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onTap,
          child: Icon(icon, size: 22, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

/// Tab Utas: banner utas tersemat, lalu daftar utas.
class _ThreadsTab extends StatelessWidget {
  const _ThreadsTab({required this.communityName, required this.canModerate});

  final String communityName;
  final bool canModerate;

  Future<void> _togglePin(BuildContext context, ThreadPost t) async {
    final p = context.read<ThreadsProvider>();
    final wasPinned = t.isPinned;
    final ok = wasPinned ? await p.unpin(t.id) : await p.pin(t.id);
    if (!context.mounted) return;
    if (ok) {
      await FeedbackDialog.success(
        context,
        title: wasPinned ? 'Sematan dilepas' : 'Utas disematkan',
        message: wasPinned
            ? 'Utas tidak lagi disematkan di komunitas.'
            : 'Utas ditampilkan di bagian atas komunitas.',
      );
    } else {
      await FeedbackDialog.error(
        context,
        title: wasPinned ? 'Gagal melepas sematan' : 'Gagal menyematkan utas',
        message: p.actionError ?? 'Terjadi kesalahan. Coba lagi.',
      );
    }
  }

  Widget? _menuFor(BuildContext context, ThreadPost t) {
    if (!canModerate) return null;
    return ThreadMenuButton(
      isPinned: t.isPinned,
      onTogglePin: () => _togglePin(context, t),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThreadsProvider>();

    if (p.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl * 2),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (p.loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text(p.loadError!, style: AppTextStyles.body),
            TextButton(onPressed: p.load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    if (p.threads.isEmpty) return const _ThreadsEmptyState();

    final pinned = p.pinned;
    return Column(
      children: [
        if (pinned != null)
          PinnedThreadBanner(
            thread: pinned,
            communityName: communityName,
            menu: _menuFor(context, pinned),
          ),
        for (final t in p.regular)
          ThreadCard(thread: t, menu: _menuFor(context, t)),
      ],
    );
  }
}

/// Keadaan kosong tab Utas untuk komunitas baru (0 utas).
class _ThreadsEmptyState extends StatelessWidget {
  const _ThreadsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl * 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forum_outlined, size: 56, color: AppColors.textHint),
          SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada utas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Jadilah yang pertama memulai diskusi di komunitas ini.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime d) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.community, required this.moderators});

  final Community community;
  final Future<List<Moderator>> moderators;

  @override
  Widget build(BuildContext context) {
    final rules = community.rules;
    final created = community.createdAt;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Informasi Komunitas'),
          if (created != null)
            _InfoRow(
              Icons.calendar_today_outlined,
              'Tanggal Dibuat',
              _formatDate(created),
            ),
          _InfoRow(
            Icons.category_outlined,
            'Kategori',
            community.category.label,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Deskripsi'),
          Text(community.description, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Tim Moderator Komunitas'),
          FutureBuilder<List<Moderator>>(
            future: moderators,
            builder: (context, snap) {
              final list = snap.data;
              if (list == null) {
                return snap.hasError
                    ? const Text(
                        'Gagal memuat moderator',
                        style: AppTextStyles.body,
                      )
                    : const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      );
              }
              return Column(
                children: [
                  for (final m in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.chip,
                            foregroundColor: AppColors.primary,
                            child: Text(m.name.substring(0, 1).toUpperCase()),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.name, style: AppTextStyles.fieldLabel),
                                Text(
                                  m.isCreator
                                      ? 'Pembuat komunitas'
                                      : 'Moderator',
                                  style: AppTextStyles.helper,
                                ),
                              ],
                            ),
                          ),
                          CategoryBadge(label: m.isCreator ? 'Pembuat' : 'Mod'),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          if (rules != null && rules.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle('Aturan Komunitas'),
            Text(rules, style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.helper),
                Text(value, style: AppTextStyles.fieldLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
