import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unand_space/models/community.dart';
import 'package:unand_space/repositories/community_repository.dart';
import 'package:unand_space/theme/app_colors.dart';
import 'package:unand_space/theme/app_spacing.dart';
import 'package:unand_space/theme/app_text_styles.dart';
import 'package:unand_space/viewmodels/moderators_provider.dart';
import 'package:unand_space/widgets/community/community_text_field.dart';
import 'package:unand_space/widgets/community/feedback_dialog.dart';
import 'package:unand_space/widgets/community/revoke_moderator_dialog.dart';

/// Dibuka dari menu titik tiga "Kelola Moderator" (hanya pembuat).
class ManageModeratorsScreen extends StatelessWidget {
  const ManageModeratorsScreen({super.key, required this.community});

  final Community community;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ModeratorsProvider(
        repository: ctx.read<CommunityRepository>(),
        communityId: community.id,
      ),
      child: const _ManageView(),
    );
  }
}

class _ManageView extends StatefulWidget {
  const _ManageView();

  @override
  State<_ManageView> createState() => _ManageViewState();
}

class _ManageViewState extends State<_ManageView> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _appoint() async {
    final p = context.read<ModeratorsProvider>();
    final ok = await p.appoint(_input.text);
    if (!mounted) return;
    if (ok) {
      _input.clear();
      await FeedbackDialog.success(
        context,
        title: 'Moderator ditunjuk',
        message: 'Moderator baru berhasil ditambahkan.',
      );
    } else if (p.actionError != null) {
      await FeedbackDialog.error(
        context,
        title: 'Gagal menunjuk moderator',
        message: p.actionError!,
      );
    }
  }

  Future<void> _revoke(Moderator m) async {
    final p = context.read<ModeratorsProvider>();
    final confirmed = await RevokeModeratorDialog.show(context, name: m.name);
    if (!confirmed || !mounted) return;
    final done = await p.revoke(m);
    if (!mounted) return;
    if (done) {
      await FeedbackDialog.success(
        context,
        title: 'Moderator dicabut',
        message: '${m.name} tidak lagi menjadi moderator.',
      );
    } else {
      await FeedbackDialog.error(
        context,
        title: 'Gagal mencabut moderator',
        message: p.actionError ?? 'Terjadi kesalahan. Coba lagi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ModeratorsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        title: const Text('Kelola Moderator', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                CommunityTextField(
                  label: 'Tunjuk Moderator Baru',
                  controller: _input,
                  onChanged: (_) => p.clearIdentifierError(),
                  maxLength: 50,
                  hint: 'Nama pengguna atau surel',
                  helper: 'Moderator dapat menyematkan utas, membuat pengumuman, dan memproses laporan.',
                  errorText: p.identifierError,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: p.isBusy ? null : _appoint,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                    child: p.isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Text(
                            'Tunjuk Moderator',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Tim Moderator (${p.moderators.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (p.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (p.loadError != null)
                  Column(
                    children: [
                      Text(p.loadError!, style: AppTextStyles.body),
                      TextButton(
                        onPressed: p.load,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  )
                else
                  for (final m in p.moderators)
                    _ModeratorTile(moderator: m, onRevoke: () => _revoke(m)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeratorTile extends StatelessWidget {
  const _ModeratorTile({required this.moderator, required this.onRevoke});

  final Moderator moderator;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final busy = context.select<ModeratorsProvider, bool>((p) => p.isBusy);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.chip,
            foregroundColor: AppColors.primary,
            child: Text(moderator.name.substring(0, 1).toUpperCase()),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moderator.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.fieldLabel,
                ),
                Text(
                  moderator.isCreator ? 'Pembuat komunitas' : 'Moderator',
                  style: AppTextStyles.helper,
                ),
              ],
            ),
          ),
          if (!moderator.isCreator)
            IconButton(
              tooltip: 'Cabut moderator',
              onPressed: busy ? null : onRevoke,
              icon: const Icon(
                Icons.person_remove_outlined,
                color: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}
