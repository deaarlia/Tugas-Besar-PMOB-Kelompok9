import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/attachments.dart';
import '../theme/app_theme.dart';
import '../utils/photo_compressor.dart';
import '../utils/validators.dart';
import '../widgets/app_snackbar.dart';

typedef SubmitComment = Future<String?> Function({
  required String content,
  required List<Uint8List> photos,
  required DocumentAttachment? document,
});

class CommentComposerScreen extends StatefulWidget {
  const CommentComposerScreen({
    super.key,
    required this.replyingTo,
    required this.initialContent,
    required this.onSubmit,
  });

  final String replyingTo;
  final String initialContent;
  final SubmitComment onSubmit;

  @override
  State<CommentComposerScreen> createState() => _CommentComposerScreenState();
}

class _CommentComposerScreenState extends State<CommentComposerScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialContent,
  );
  final _picker = ImagePicker();
  final List<Uint8List> _photos = [];
  DocumentAttachment? _document;
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_photos.length >= Validators.maxPhotoCount) {
      AppSnackbar.showError(
        context,
        'Maksimal ${Validators.maxPhotoCount} foto.',
      );
      return;
    }
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: source == ImageSource.camera ? 100 : null,
        maxWidth: source == ImageSource.camera ? 2560 : null,
        maxHeight: source == ImageSource.camera ? 2560 : null,
      );
      if (!mounted || file == null) return;
      if (source != ImageSource.camera) {
        final size = await file.length();
        if (!mounted) return;
        final validation = Validators.photoFile(
          file.name,
          size,
          mimeType: file.mimeType,
        );
        if (validation != null) {
          AppSnackbar.showError(context, validation);
          return;
        }
      }
      final bytes = await file.readAsBytes();
      final processed = source == ImageSource.camera
          ? await compressPhoto(bytes)
          : bytes;
      if (!mounted) return;
      final validation = Validators.photoFile(
        source == ImageSource.camera ? 'camera.jpg' : file.name,
        processed.length,
        mimeType: source == ImageSource.camera ? 'image/jpeg' : file.mimeType,
      );
      if (validation != null) {
        AppSnackbar.showError(context, validation);
        return;
      }
      setState(() => _photos.add(processed));
    } catch (error) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memilih foto: $error');
      }
    }
  }

  Future<void> _pickDocument() async {
    if (_document != null) {
      AppSnackbar.showError(context, 'Maksimal satu file dapat dilampirkan.');
      return;
    }
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: Validators.documentExtensions,
      );
      if (!mounted || file == null) return;
      final size = await file.length();
      if (!mounted) return;
      if (size == null) {
        AppSnackbar.showError(
          context,
          'Ukuran file tidak dapat dibaca. Coba file lain.',
        );
        return;
      }
      var validation = Validators.documentFile(file.name, size);
      if (validation != null) {
        AppSnackbar.showError(context, validation);
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      validation = Validators.documentFile(file.name, bytes.length);
      if (validation != null) {
        AppSnackbar.showError(context, validation);
        return;
      }
      setState(() {
        _document = DocumentAttachment(name: file.name, bytes: bytes);
      });
    } catch (error) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memilih file: $error');
      }
    }
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (_isSending || content.isEmpty) return;
    if (content.characters.length > 500) {
      AppSnackbar.showError(context, 'Balasan maksimal 500 karakter.');
      return;
    }
    setState(() => _isSending = true);
    final error = await widget.onSubmit(
      content: content,
      photos: List.unmodifiable(_photos),
      document: _document,
    );
    if (!mounted) return;
    setState(() => _isSending = false);
    if (error != null) {
      AppSnackbar.showError(context, error);
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.replyingTo == 'utas ini' ? 'Buat komentar' : 'Balas komentar',
        ),
        actions: [
          TextButton(
            onPressed: _isSending ? null : _submit,
            child: const Text('Kirim'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                'Membalas ${widget.replyingTo}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  minLines: 8,
                  maxLines: null,
                  maxLength: 500,
                  style: const TextStyle(
                    fontSize: AppTypography.body,
                    height: 1.45,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Tulis balasan...',
                    alignLabelWithHint: true,
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            _buildAttachments(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Pilih foto',
                    onPressed: _isSending
                        ? null
                        : () => _pickPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_outlined),
                  ),
                  IconButton(
                    tooltip: 'Ambil foto',
                    onPressed: _isSending
                        ? null
                        : () => _pickPhoto(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                  IconButton(
                    tooltip: 'Lampirkan file',
                    onPressed: _isSending ? null : _pickDocument,
                    icon: const Icon(Icons.attach_file),
                  ),
                  const Spacer(),
                  Text(
                    '${_controller.text.characters.length}/500',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: AppTypography.label,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Kirim balasan',
                    onPressed: _isSending ? null : _submit,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments() {
    if (_photos.isEmpty && _document == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var index = 0; index < _photos.length; index++)
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _photos[index],
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: -5,
                  top: -5,
                  child: IconButton(
                    tooltip: 'Hapus foto',
                    onPressed: () => setState(() => _photos.removeAt(index)),
                    icon: const Icon(Icons.cancel, size: 18),
                    constraints: const BoxConstraints.tightFor(
                      width: 24,
                      height: 24,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          if (_document != null)
            InputChip(
              avatar: const Icon(Icons.description_outlined, size: 18),
              label: Text(_document!.name),
              onDeleted: () => setState(() => _document = null),
            ),
        ],
      ),
    );
  }
}
