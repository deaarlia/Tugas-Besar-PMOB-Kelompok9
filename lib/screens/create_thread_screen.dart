import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/attachments.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../viewmodels/create_thread_view_model.dart';
import '../widgets/thread_attachments_section.dart';
import '../widgets/thread_composer_toolbar.dart';
import '../widgets/state_views.dart';
import '../widgets/topic_dialog.dart';

class CreateThreadScreen extends StatefulWidget {
  // DATA DITERIMA dari HomeScreen lewat arguments
  final UserProfile author;
  final ThreadPost? editingThread;
  const CreateThreadScreen({
    super.key,
    required this.author,
    this.editingThread,
  });

  @override
  State<CreateThreadScreen> createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends State<CreateThreadScreen> {
  static const int _maxTopics = CreateThreadViewModel.maxTopics;
  static const int _maxContent = CreateThreadViewModel.maxContent;

  final _formKey = GlobalKey<FormState>();
  late final CreateThreadViewModel _viewModel = CreateThreadViewModel(
    author: widget.author,
    editingThread: widget.editingThread,
  );

  TextEditingController get _titleController => _viewModel.titleController;
  TextEditingController get _contentController => _viewModel.contentController;
  List<String> get _topics => _viewModel.topics;
  List<Uint8List> get _photos => _viewModel.photos;
  DocumentAttachment? get _document => _viewModel.document;
  bool get _isAnonymous => _viewModel.isAnonymous;
  bool get _isSubmitting => _viewModel.isSubmitting;
  String? get _errorMessage => _viewModel.errorMessage;
  bool get _hasUnsavedInput => _viewModel.hasUnsavedInput;
  bool get _canPost => _viewModel.canPost;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showMessage('Periksa kembali isian yang masih salah.');
      return;
    }

    final thread = await _viewModel.submit();
    if (mounted && thread != null) {
      Navigator.pop<ThreadPost>(context, thread);
    }
  }

  // ---------------------------------------------------------------- Lampiran

  /// Lampiran foto: membuka galeri (di web: file explorer), lalu memvalidasi
  /// format (JPG/PNG) dan ukuran (maks 3 MB) sebelum foto ditambahkan.
  Future<void> _attachPhoto() async {
    FocusScope.of(context).unfocus();
    final message = await _viewModel.attachPhoto();
    if (mounted && message != null) _showMessage(message);
  }

  Future<void> _capturePhoto() async {
    FocusScope.of(context).unfocus();
    final message = await _viewModel.attachPhoto(source: ImageSource.camera);
    if (mounted && message != null) _showMessage(message);
  }

  Future<void> _attachDocument() async {
    FocusScope.of(context).unfocus();
    final message = await _viewModel.attachDocument();
    if (mounted && message != null) _showMessage(message);
  }

  Future<void> _addTopic() async {
    final topic = await showDialog<String>(
      context: context,
      builder: (_) => TopicDialog(existing: _topics),
    );
    if (!mounted || topic == null) return;
    final message = _viewModel.addTopic(topic);
    if (message != null) _showMessage(message);
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buang utas?'),
        content: const Text(
          'Isi utas akan hilang tanpa disimpan. Yakin ingin keluar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ------------------------------------------------------------------- Build

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => PopScope<Object?>(
        canPop: !_hasUnsavedInput || _isSubmitting,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldLeave = await _confirmDiscard();
          if (context.mounted && shouldLeave) Navigator.pop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(
              _viewModel.isEditing ? 'Edit Utas' : 'Buat Utas Baru',
              style: TextStyle(
                fontSize: AppTypography.pageTitle,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAuthorRow(),
                          const Divider(height: 1, color: AppColors.border),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_errorMessage != null) ...[
                                  ErrorBanner(message: _errorMessage!),
                                  const SizedBox(height: 12),
                                ],
                                _buildTitleField(),
                                const SizedBox(height: 8),
                                _buildTopics(),
                                const SizedBox(height: 12),
                                _buildContentField(),
                              ],
                            ),
                          ),
                          ThreadAttachmentsSection(
                            photos: _photos,
                            document: _document,
                            enabled: !_isSubmitting,
                            onRemovePhoto: _viewModel.removePhoto,
                            onRemoveDocument: _viewModel.removeDocument,
                          ),
                          const Divider(height: 1, color: AppColors.border),
                          _buildAnonymousSwitch(),
                        ],
                      ),
                    ),
                  ),
                ),
                ThreadComposerToolbar(
                  titleController: _titleController,
                  contentController: _contentController,
                  maxContent: _maxContent,
                  isSubmitting: _isSubmitting,
                  canPost: () => _canPost,
                  postLabel: _viewModel.isEditing ? 'Simpan' : 'Posting',
                  onAttachPhoto: _attachPhoto,
                  onCapturePhoto: _capturePhoto,
                  onAttachDocument: _attachDocument,
                  onPost: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Menampilkan data pengguna yang DITERIMA dari route (UserProfile):
  /// Nama penulis dan label "FTI • Unand".
  Widget _buildAuthorRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.avatarBg,
            child: Text(
              widget.author.initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: AppTypography.label,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.author.name,
                style: const TextStyle(
                  fontSize: AppTypography.body,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                widget.author.campusLabel,
                style: const TextStyle(
                  fontSize: AppTypography.caption,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      enabled: !_isSubmitting,
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      style: const TextStyle(
        fontSize: AppTypography.sectionTitle,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      decoration: const InputDecoration(
        hintText: 'Judul utas...',
        hintStyle: TextStyle(color: Color(0xFFA3ACA8)),
        border: InputBorder.none,
        counterText: '',
        contentPadding: EdgeInsets.zero,
      ),
      validator: (v) => Validators.minLength(
        v,
        Validators.minTitleLength,
        fieldName: 'Judul',
      ),
    );
  }

  /// Topik bersifat opsional: hanya untuk pengelompokan, tidak tampil di kartu.
  Widget _buildTopics() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ..._topics.map(
          (t) => Chip(
            label: Text('#$t'),
            backgroundColor: AppColors.chipBg,
            side: BorderSide.none,
            labelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: AppTypography.caption,
            ),
            onDeleted: _isSubmitting ? null : () => _viewModel.removeTopic(t),
          ),
        ),
        if (_topics.length < _maxTopics)
          ActionChip(
            avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
            label: const Text('Tambah Topik (opsional)'),
            labelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: AppTypography.caption,
            ),
            backgroundColor: Colors.white,
            shape: const StadiumBorder(),
            side: const BorderSide(color: AppColors.border),
            onPressed: _isSubmitting ? null : _addTopic,
          ),
      ],
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      enabled: !_isSubmitting,
      minLines: 8,
      maxLines: null,
      maxLength: _maxContent,
      style: const TextStyle(
        fontSize: AppTypography.body,
        height: 1.45,
        color: AppColors.textDark,
      ),
      decoration: const InputDecoration(
        hintText: 'Tuliskan isi utas, pertanyaan, atau informasi kampus...',
        hintStyle: TextStyle(color: Color(0xFFA3ACA8)),
        border: InputBorder.none,
        counterText: '',
        contentPadding: EdgeInsets.zero,
      ),
      validator: (v) => Validators.minLength(
        v,
        Validators.minContentLength,
        fieldName: 'Isi utas',
      ),
    );
  }

  Widget _buildAnonymousSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.visibility_off_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Anonim',
                  style: TextStyle(
                    fontSize: AppTypography.body,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Nama & identitas Anda disembunyikan.',
                  style: TextStyle(
                    fontSize: AppTypography.caption,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _isAnonymous,
              activeThumbColor: AppColors.primary,
              onChanged: _isSubmitting ? null : _viewModel.setAnonymous,
            ),
          ),
        ],
      ),
    );
  }
}
