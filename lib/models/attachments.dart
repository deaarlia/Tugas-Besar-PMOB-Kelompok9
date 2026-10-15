import 'dart:typed_data';

/// Draf polling (mockup): satu pertanyaan dengan 2-4 opsi.
class PollDraft {
  final String question;
  final List<String> options;

  const PollDraft({required this.question, required this.options});
}

/// Dokumen yang dipilih pengguna untuk dilampirkan ke postingan.
class DocumentAttachment {
  final String name;
  final Uint8List bytes;

  const DocumentAttachment({required this.name, required this.bytes});

  String get sizeLabel {
    final sizeInKb = bytes.length / 1024;
    if (sizeInKb < 1) return '<1 KB';
    if (sizeInKb < 1024) return '${sizeInKb.toStringAsFixed(0)} KB';
    return '${(sizeInKb / 1024).toStringAsFixed(1)} MB';
  }
}
