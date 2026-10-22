/// Validator reusable.
/// return null -> VALID, return 'pesan' -> TIDAK VALID.
class Validators {
  Validators._();

  static const int minTitleLength = 5;
  static const int minContentLength = 20;

  static const List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'odt',
    'ods',
    'odp',
    'rtf',
    'tex',
    'bib',
    'txt',
    'csv',
  ];

  static const int maxDocumentBytes = 10 * 1024 * 1024;
  static const int maxPhotoCount = 3;
  static const int maxPhotoBytes = 3 * 1024 * 1024;
  static const List<String> photoExtensions = ['jpg', 'jpeg', 'png'];

  static String? requiredField(
    String? value, {
    String fieldName = 'Field ini',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'Field ini',
  }) {
    final requiredError = requiredField(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;
    if (value!.trim().length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  static String? documentFile(String name, int sizeBytes) {
    final extension = name.contains('.')
        ? name.split('.').last.toLowerCase()
        : '';
    if (!documentExtensions.contains(extension)) {
      return 'Format dokumen tidak didukung. Gunakan PDF, DOC/DOCX, '
          'XLS/XLSX, PPT/PPTX, ODT/ODS/ODP, RTF, TEX, BIB, TXT, atau CSV.';
    }
    if (sizeBytes == 0) return 'Dokumen kosong tidak dapat dilampirkan.';
    if (sizeBytes > maxDocumentBytes) {
      return 'Ukuran dokumen maksimal 10 MB.';
    }
    return null;
  }

  static String? photoFile(String name, int sizeBytes, {String? mimeType}) {
    final formatError = photoFormat(name, mimeType: mimeType);
    if (formatError != null) return formatError;
    if (sizeBytes == 0) return 'Foto kosong tidak dapat dilampirkan.';
    if (sizeBytes > maxPhotoBytes) {
      return 'Ukuran foto maksimal 3 MB.';
    }
    return null;
  }

  static String? photoFormat(String name, {String? mimeType}) {
    final extension = name.contains('.')
        ? name.split('.').last.toLowerCase()
        : '';
    final mime = mimeType?.toLowerCase();
    final validExtension = photoExtensions.contains(extension);
    final validMime = mime == 'image/jpeg' || mime == 'image/png';
    if (!validExtension && !validMime) {
      return 'Format foto harus JPG atau PNG.';
    }
    return null;
  }

  static String? photoCount(int currentCount) {
    if (currentCount >= maxPhotoCount) {
      return 'Maksimal $maxPhotoCount foto.';
    }
    return null;
  }
}
