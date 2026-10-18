import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/thread_repository.dart';
import '../models/attachments.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../utils/photo_compressor.dart';
import '../utils/validators.dart';

class CreateThreadViewModel extends ChangeNotifier {
  CreateThreadViewModel({
    required this.author,
    this.editingThread,
    ThreadRepository? repository,
    ImagePicker? imagePicker,
  }) : _repository = repository ?? ThreadRepository.instance,
       _imagePicker = imagePicker ?? ImagePicker() {
    if (editingThread != null) {
      titleController.text = editingThread!.title;
      contentController.text = editingThread!.content;
      _topics.addAll(editingThread!.topics);
      _photos.addAll(editingThread!.photos);
      _document = editingThread!.document;
      _isAnonymous = editingThread!.isAnonymous;
      _community = editingThread!.community;
    }
    _originalTitle = titleController.text;
    _originalContent = contentController.text;
    _originalTopics = List.of(_topics);
    _originalPhotoCount = _photos.length;
    _originalDocument = _document;
    _originalAnonymous = _isAnonymous;
    titleController.addListener(_notifyListeners);
    contentController.addListener(_notifyListeners);
  }

  static const int maxTopics = 3;
  static const int maxContent = 1000;

  final UserProfile author;
  final ThreadPost? editingThread;
  final ThreadRepository _repository;
  final ImagePicker _imagePicker;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final List<String> _topics = [];
  final List<Uint8List> _photos = [];
  DocumentAttachment? _document;
  bool _isAnonymous = false;
  String _community = 'Umum';
  late final String _originalTitle;
  late final String _originalContent;
  late final List<String> _originalTopics;
  late final int _originalPhotoCount;
  late final DocumentAttachment? _originalDocument;
  late final bool _originalAnonymous;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _disposed = false;

  List<String> get topics => List.unmodifiable(_topics);
  List<Uint8List> get photos => List.unmodifiable(_photos);
  DocumentAttachment? get document => _document;
  bool get isAnonymous => _isAnonymous;
  bool get isEditing => editingThread != null;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get hasAttachments => _photos.isNotEmpty || _document != null;
  bool get hasUnsavedInput {
    if (!isEditing) {
      return titleController.text.isNotEmpty ||
          contentController.text.isNotEmpty ||
          _topics.isNotEmpty ||
          hasAttachments;
    }
    return titleController.text != _originalTitle ||
        contentController.text != _originalContent ||
        !_listEquals(_topics, _originalTopics) ||
        _photos.length != _originalPhotoCount ||
        _document != _originalDocument ||
        _isAnonymous != _originalAnonymous;
  }

  bool get canPost =>
      !_isSubmitting &&
      titleController.text.trim().length >= Validators.minTitleLength &&
      contentController.text.trim().length >= Validators.minContentLength;

  void setAnonymous(bool value) {
    _isAnonymous = value;
    _notifyListeners();
  }

  void removePhoto(int index) {
    _photos.removeAt(index);
    _notifyListeners();
  }

  void removeDocument() {
    _document = null;
    _notifyListeners();
  }

  void removeTopic(String topic) {
    _topics.remove(topic);
    _notifyListeners();
  }

  String? addTopic(String topic) {
    if (_topics.length >= maxTopics) return 'Maksimal $maxTopics topik.';
    _topics.add(topic);
    _notifyListeners();
    return null;
  }

  Future<ThreadPost?> submit() async {
    _isSubmitting = true;
    _errorMessage = null;
    _notifyListeners();

    try {
      final thread = isEditing
          ? await _repository.updateThread(
              threadId: editingThread!.id,
              authorName: author.name,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              topics: _topics,
              photos: _photos,
              isAnonymous: _isAnonymous,
              community: _community,
              document: _document,
              clearDocument: _originalDocument != null && _document == null,
            )
          : await _repository.createThread(
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              topics: _topics,
              photos: _photos,
              document: _document,
              author: author,
              isAnonymous: _isAnonymous,
              community: _community,
            );
      return thread;
    } on ThreadException catch (e) {
      _setSubmissionError(e.message);
      return null;
    } catch (_) {
      _setSubmissionError('Terjadi kesalahan. Coba lagi nanti.');
      return null;
    }
  }

  Future<String?> attachPhoto({
    ImageSource source = ImageSource.gallery,
  }) async {
    final countError = Validators.photoCount(_photos.length);
    if (countError != null) return countError;

    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: source == ImageSource.camera ? 100 : null,
        maxWidth: source == ImageSource.camera ? 2560 : null,
        maxHeight: source == ImageSource.camera ? 2560 : null,
      );
      if (_disposed || file == null) return null;

      final sizeBytes = await file.length();
      if (_disposed) return null;

      if (source == ImageSource.camera) {
        if (sizeBytes == 0) {
          return 'Foto kosong tidak dapat dilampirkan.';
        }
        final formatError = Validators.photoFormat(
          file.name,
          mimeType: file.mimeType,
        );
        if (formatError != null) return formatError;

        final bytes = await file.readAsBytes();
        if (_disposed) return null;
        final compressed = await compressPhoto(bytes);
        if (_disposed) return null;
        final validationError = Validators.photoFile(
          'camera.jpg',
          compressed.length,
          mimeType: 'image/jpeg',
        );
        if (validationError != null) return validationError;

        _photos.add(compressed);
        _notifyListeners();
        return null;
      }

      final validationError = Validators.photoFile(
        file.name,
        sizeBytes,
        mimeType: file.mimeType,
      );
      if (validationError != null) return validationError;

      final bytes = await file.readAsBytes();
      if (_disposed) return null;
      final actualSizeError = Validators.photoFile(
        file.name,
        bytes.length,
        mimeType: file.mimeType,
      );
      if (actualSizeError != null) return actualSizeError;

      _photos.add(bytes);
      _notifyListeners();
      return null;
    } catch (error) {
      if (_disposed) return null;
      if (source == ImageSource.camera) {
        return 'Gagal mengambil atau memproses foto dari kamera: $error';
      }
      return 'Gagal membuka galeri. Coba lagi.';
    }
  }

  Future<String?> attachDocument() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: Validators.documentExtensions,
      );
      if (_disposed || file == null) return null;

      final sizeBytes = await file.length();
      if (_disposed) return null;
      if (sizeBytes == null) {
        return 'Ukuran dokumen tidak dapat dibaca. Coba berkas lain.';
      }

      final validationError = Validators.documentFile(file.name, sizeBytes);
      if (validationError != null) return validationError;

      final bytes = await file.readAsBytes();
      if (_disposed) return null;
      final actualSizeError = Validators.documentFile(file.name, bytes.length);
      if (actualSizeError != null) return actualSizeError;

      _document = DocumentAttachment(name: file.name, bytes: bytes);
      _notifyListeners();
      return null;
    } catch (e) {
      if (_disposed) return null;
      return 'Gagal memilih dokumen: $e';
    }
  }

  void _setSubmissionError(String message) {
    _errorMessage = message;
    _isSubmitting = false;
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  bool _listEquals(List<String> first, List<String> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    titleController
      ..removeListener(_notifyListeners)
      ..dispose();
    contentController
      ..removeListener(_notifyListeners)
      ..dispose();
    super.dispose();
  }
}
