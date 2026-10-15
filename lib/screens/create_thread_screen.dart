import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/thread_repository.dart';
import '../models/attachments.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/thread_attachments_section.dart';
import '../widgets/thread_composer_toolbar.dart';
import '../widgets/state_views.dart';
import '../widgets/topic_dialog.dart';

class CreateThreadScreen extends StatefulWidget {
  // DATA DITERIMA dari HomeScreen lewat arguments
  final UserProfile author;
  const CreateThreadScreen({super.key, required this.author});

  @override
  State<CreateThreadScreen> createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends State<CreateThreadScreen> {
  static const int _maxTopics = 3;
  static const int _maxContent = 1000;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _picker = ImagePicker();
  final _repository = ThreadRepository.instance;

  // STATE form
  final List<String> _topics = []; // opsional, hanya untuk pengelompokan
  final List<Uint8List> _photos = [];
  DocumentAttachment? _document;
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _hasAttachments => _photos.isNotEmpty || _document != null;

  bool get _hasUnsavedInput =>
      _titleController.text.isNotEmpty ||
      _contentController.text.isNotEmpty ||
      _topics.isNotEmpty ||
      _hasAttachments;

  /// Tombol "Posting" aktif hanya jika judul dan isi memenuhi aturan.
  bool get _canPost =>
      !_isSubmitting &&
      _titleController.text.trim().length >= Validators.minTitleLength &&
      _contentController.text.trim().length >= Validators.minContentLength;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // EVENT: user menekan tombol "Posting"
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    // VALIDATION: semua validator di Form dijalankan
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showMessage('Periksa kembali isian yang masih salah.');
      return; // user tetap di form
    }

    // STATE -> loading
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final thread = await _repository.createThread(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        topics: _topics,
        photos: _photos,
        document: _document,
        author: widget.author,
        isAnonymous: _isAnonymous,
      );
      if (!mounted) return;

      // NAVIGATION/RESULT: tutup form sambil mengembalikan ThreadPost
      Navigator.pop<ThreadPost>(context, thread);
    } on ThreadException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      const msg = 'Terjadi kesalahan. Coba lagi nanti.';
      setState(() {
        _errorMessage = msg;
        _isSubmitting = false;
      });
    }
  }

  // ---------------------------------------------------------------- Lampiran

  /// Lampiran foto: membuka galeri (di web: file explorer), lalu memvalidasi
  /// format (JPG/PNG) dan ukuran (maks 3 MB) sebelum foto ditambahkan.
  Future<void> _attachPhoto() async {
    final countError = Validators.photoCount(_photos.length);
    if (countError != null) {
      _showMessage(countError);
      return;
    }
    FocusScope.of(context).unfocus();
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (!mounted || file == null) return; // user membatalkan pilihan

      final sizeBytes = await file.length();
      if (!mounted) return;
      final validationError = Validators.photoFile(
        file.name,
        sizeBytes,
        mimeType: file.mimeType,
      );
      if (validationError != null) {
        _showMessage(validationError);
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final actualSizeError = Validators.photoFile(
        file.name,
        bytes.length,
        mimeType: file.mimeType,
      );
      if (actualSizeError != null) {
        _showMessage(actualSizeError);
        return;
      }
      setState(() => _photos.add(bytes));
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal membuka galeri. Coba lagi.');
    }
  }

  Future<void> _attachDocument() async {
    FocusScope.of(context).unfocus();
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: Validators.documentExtensions,
      );
      if (!mounted || file == null) return;

      final sizeBytes = await file.length();
      if (!mounted) return;
      if (sizeBytes == null) {
        _showMessage('Ukuran dokumen tidak dapat dibaca. Coba berkas lain.');
        return;
      }

      final validationError = Validators.documentFile(file.name, sizeBytes);
      if (validationError != null) {
        _showMessage(validationError);
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final actualSizeError = Validators.documentFile(file.name, bytes.length);
      if (actualSizeError != null) {
        _showMessage(actualSizeError);
        return;
      }

      setState(
        () => _document = DocumentAttachment(name: file.name, bytes: bytes),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal memilih dokumen: $e');
    }
  }

  Future<void> _addTopic() async {
    if (_topics.length >= _maxTopics) {
      _showMessage('Maksimal $_maxTopics topik.');
      return;
    }
    final topic = await showDialog<String>(
      context: context,
      builder: (_) => TopicDialog(existing: _topics),
    );
    if (!mounted || topic == null) return;
    setState(() => _topics.add(topic));
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buang utas?'),
        content: const Text('Isi utas akan hilang tanpa disimpan. Yakin ingin keluar?'),
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
      listenable: Listenable.merge([_titleController, _contentController]),
      builder: (context, child) => PopScope<Object?>(
        canPop: !_hasUnsavedInput || _isSubmitting,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldLeave = await _confirmDiscard();
          if (context.mounted && shouldLeave) Navigator.pop(context);
        },
        child: child!,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            'Buat Utas Baru',
            style: TextStyle(
              fontSize: 17,
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
                          onRemovePhoto: (index) =>
                              setState(() => _photos.removeAt(index)),
                          onRemoveDocument: () =>
                              setState(() => _document = null),
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
                onAttachPhoto: _attachPhoto,
                onAttachDocument: _attachDocument,
                onPost: _submit,
              ),
            ],
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
                fontSize: 12,
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                widget.author.campusLabel,
                style: const TextStyle(
                  fontSize: 11.5,
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
        fontSize: 17,
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
              fontSize: 11.5,
            ),
            onDeleted: _isSubmitting
                ? null
                : () => setState(() => _topics.remove(t)),
          ),
        ),
        if (_topics.length < _maxTopics)
          ActionChip(
            avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
            label: const Text('Tambah Topik (opsional)'),
            labelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
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
        fontSize: 14,
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
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Nama & identitas Anda disembunyikan.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
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
              onChanged: _isSubmitting
                  ? null
                  : (v) => setState(() => _isAnonymous = v),
            ),
          ),
        ],
      ),
    );
  }
}
