import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unand_space/models/community.dart';
import 'package:unand_space/repositories/community_repository.dart';
import 'package:unand_space/theme/app_colors.dart';
import 'package:unand_space/theme/app_spacing.dart';
import 'package:unand_space/theme/app_text_styles.dart';
import 'package:unand_space/viewmodels/community_form_provider.dart';
import 'package:unand_space/widgets/community/category_chips.dart';
import 'package:unand_space/widgets/community/community_text_field.dart';
import 'package:unand_space/widgets/community/cover_icon_picker.dart';
import 'package:unand_space/widgets/community/danger_zone.dart';
import 'package:unand_space/widgets/community/delete_community_dialog.dart';
import 'package:unand_space/widgets/community/feedback_dialog.dart';
import 'package:unand_space/widgets/community/guideline_card.dart';
import 'package:unand_space/widgets/community/privacy_switch_card.dart';

/// Form bersama untuk Buat (initial == null) dan Ubah (initial != null).
/// Membutuhkan `Provider<CommunityRepository>` di atas widget tree.
class CommunityFormScreen extends StatelessWidget {
  const CommunityFormScreen({super.key, this.initial});

  final Community? initial;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CommunityFormProvider(
        repository: ctx.read<CommunityRepository>(),
        initial: initial,
      ),
      child: const _CommunityFormView(),
    );
  }
}

class _CommunityFormView extends StatefulWidget {
  const _CommunityFormView();

  @override
  State<_CommunityFormView> createState() => _CommunityFormViewState();
}

class _CommunityFormViewState extends State<_CommunityFormView> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _rules;
  final _picker = ImagePicker();
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<CommunityFormProvider>();
    _name = TextEditingController(text: p.name);
    _description = TextEditingController(text: p.description);
    _rules = TextEditingController(text: p.rules);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _rules.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool cover}) async {
    if (!kIsWeb && _isPicking) return; // penjaga hanya untuk HP
    if (!kIsWeb) _isPicking = true;
    final p = context.read<CommunityFormProvider>();
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: kIsWeb ? null : 1600,
        imageQuality: kIsWeb ? null : 85,
      );
      if (file == null) return;
      if (cover && await file.length() > CommunityRules.coverMaxBytes) {
        if (!mounted) return;
        await FeedbackDialog.error(
          context,
          title: 'Sampul terlalu besar',
          message: 'Ukuran sampul maksimal 5 MB.',
        );
        return;
      }
      cover ? p.setCoverPath(file.path) : p.setIconPath(file.path);
    } catch (_) {
      if (!mounted) return;
      await FeedbackDialog.error(
        context,
        title: 'Galeri tidak dapat diakses',
        message: 'Anda tetap bisa melanjutkan tanpa gambar.',
      );
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _submit() async {
    final p = context.read<CommunityFormProvider>();
    final navigator = Navigator.of(context);
    final isEdit = p.isEdit;
    final result = await p.submit();
    if (!mounted) return;
    if (result == null) {
      if (p.submitError != null) {
        await FeedbackDialog.error(
          context,
          title: 'Gagal menyimpan',
          message: p.submitError!,
        );
      }
      return;
    }
    await FeedbackDialog.success(
      context,
      title: isEdit ? 'Perubahan tersimpan' : 'Komunitas dibuat',
      message: isEdit
          ? 'Perubahan komunitas berhasil disimpan.'
          : 'Komunitas berhasil dibuat.',
    );
    if (!mounted) return;
    navigator.pop(CommunityFormResult.saved(result));
  }

  Future<void> _confirmDelete() async {
    final p = context.read<CommunityFormProvider>();
    final navigator = Navigator.of(context);
    final name = p.initial!.name;
    final ok = await DeleteCommunityDialog.show(context, communityName: name);
    if (!ok || !mounted) return;
    final deleted = await p.delete();
    if (!mounted) return;
    if (deleted) {
      await FeedbackDialog.success(
        context,
        title: 'Komunitas dihapus',
        message: 'Komunitas $name berhasil dihapus.',
      );
      if (!mounted) return;
      navigator.pop(const CommunityFormResult.deleted());
    } else if (p.submitError != null) {
      await FeedbackDialog.error(
        context,
        title: 'Gagal menghapus',
        message: p.submitError!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CommunityFormProvider>();
    final isEdit = p.isEdit;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: p.isBusy ? null : () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          isEdit ? 'Ubah Komunitas' : 'Buat Komunitas Baru',
          style: AppTextStyles.appBarTitle,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: FilledButton(
                onPressed: p.canSubmit ? _submit : null,
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
                    : Text(
                        isEdit ? 'Simpan' : 'Buat',
                        style: AppTextStyles.button,
                      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoverIconPicker(
                    coverPath: p.coverPath,
                    coverUrl: p.initial?.coverUrl,
                    iconPath: p.iconPath,
                    iconUrl: p.initial?.iconUrl,
                    onPickCover: () => _pickImage(cover: true),
                    onPickIcon: () => _pickImage(cover: false),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CommunityTextField(
                    label: 'Nama Komunitas',
                    required: true,
                    controller: _name,
                    onChanged: p.setName,
                    maxLength: CommunityRules.nameMax,
                    hint: 'Contoh: Komunitas Robotika Unand',
                    helper: 'Gunakan nama yang mudah dikenali mahasiswa',
                    errorText: p.nameError,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CategoryChips(
                    selected: p.category,
                    onSelected: p.setCategory,
                    errorText: p.categoryError,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CommunityTextField(
                    label: isEdit ? 'Deskripsi' : 'Deskripsi Komunitas',
                    required: true,
                    controller: _description,
                    onChanged: p.setDescription,
                    maxLength: CommunityRules.descriptionMax,
                    hint: 'Jelaskan tujuan, visi, dan kegiatan komunitas...',
                    helper: 'Beri gambaran singkat agar calon anggota memahami fokus kegiatan.',
                    errorText: p.descriptionError,
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrivacySwitchCard(
                    value: p.isPublic,
                    onChanged: p.setPublic,
                    showHeader: !isEdit,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (!isEdit) ...[
                    CommunityTextField(
                      label: 'Aturan Dasar Komunitas',
                      trailing: 'Opsional',
                      controller: _rules,
                      onChanged: p.setRules,
                      maxLength: CommunityRules.rulesMax,
                      hint: 'Contoh: Sopan dan saling menghargai',
                      helper: 'Aturan awal yang disepakati untuk menjaga kondusivitas ruang diskusi.',
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const GuidelineCard(),
                  ] else
                    DangerZone(onDelete: _confirmDelete, enabled: !p.isBusy),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
