import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_pmob/models/community.dart';
import 'package:tugas_pmob/repositories/community_repository.dart';
import 'package:tugas_pmob/theme/app_colors.dart';
import 'package:tugas_pmob/theme/app_spacing.dart';
import 'package:tugas_pmob/theme/app_text_styles.dart';
import 'package:tugas_pmob/viewmodels/community_rules_provider.dart';
import 'package:tugas_pmob/widgets/community/community_text_field.dart';
import 'package:tugas_pmob/widgets/community/feedback_dialog.dart';

/// Dibuka dari menu titik tiga "Atur Aturan" (hanya pembuat).
/// Mengembalikan Community yang sudah diperbarui lewat Navigator.pop.
class RulesEditScreen extends StatelessWidget {
  const RulesEditScreen({super.key, required this.community});

  final Community community;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CommunityRulesProvider(
        repository: ctx.read<CommunityRepository>(),
        community: community,
      ),
      child: const _RulesView(),
    );
  }
}

class _RulesView extends StatefulWidget {
  const _RulesView();

  @override
  State<_RulesView> createState() => _RulesViewState();
}

class _RulesViewState extends State<_RulesView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<CommunityRulesProvider>().rules,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final p = context.read<CommunityRulesProvider>();
    final navigator = Navigator.of(context);
    final result = await p.submit();
    if (!mounted) return;
    if (result == null) {
      if (p.submitError != null) {
        await FeedbackDialog.error(
          context,
          title: 'Gagal menyimpan aturan',
          message: p.submitError!,
        );
      }
      return;
    }
    await FeedbackDialog.success(
      context,
      title: 'Aturan tersimpan',
      message: 'Aturan komunitas berhasil disimpan.',
    );
    if (!mounted) return;
    navigator.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CommunityRulesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: p.isSubmitting
              ? null
              : () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Atur Aturan', style: AppTextStyles.appBarTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: FilledButton(
                onPressed: p.canSubmit ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.disabledSurface,
                  disabledForegroundColor: AppColors.disabledText,
                  shape: const StadiumBorder(),
                ),
                child: p.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Text('Simpan', style: AppTextStyles.button),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: CommunityTextField(
                label: 'Aturan Komunitas',
                required: true,
                controller: _controller,
                onChanged: p.setRules,
                maxLength: CommunityRules.rulesMax,
                hint: 'Contoh: 1. Sopan dan saling menghargai',
                helper: 'Aturan ini tampil di tab Tentang dan menjadi acuan moderator saat memproses laporan.',
                errorText: p.rulesError,
                minLines: 8,
                maxLines: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
