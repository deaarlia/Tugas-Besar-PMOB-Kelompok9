import 'package:flutter_test/flutter_test.dart';
import 'package:unand_space/utils/validators.dart';

void main() {
  group('Validators.minLength thresholds', () {
    test('uses shared minimum title and content lengths', () {
      expect(
        Validators.minLength(
          'a' * (Validators.minTitleLength - 1),
          Validators.minTitleLength,
          fieldName: 'Judul',
        ),
        contains('${Validators.minTitleLength}'),
      );
      expect(
        Validators.minLength(
          'a' * Validators.minTitleLength,
          Validators.minTitleLength,
          fieldName: 'Judul',
        ),
        isNull,
      );
      expect(
        Validators.minLength(
          'a' * (Validators.minContentLength - 1),
          Validators.minContentLength,
          fieldName: 'Isi utas',
        ),
        contains('${Validators.minContentLength}'),
      );
      expect(
        Validators.minLength(
          'a' * Validators.minContentLength,
          Validators.minContentLength,
          fieldName: 'Isi utas',
        ),
        isNull,
      );
    });
  });

  group('Validators.documentFile', () {
    test(
      'accepts supported academic document extensions case-insensitively',
      () {
        expect(Validators.documentFile('materi.PDF', 1), isNull);
        expect(Validators.documentFile('laporan.docx', 1), isNull);
        expect(Validators.documentFile('nilai.xlsx', 1), isNull);
        expect(Validators.documentFile('presentasi.pptx', 1), isNull);
        expect(Validators.documentFile('data.csv', 1), isNull);
      },
    );

    test('rejects unsupported extensions', () {
      expect(Validators.documentFile('foto.jpg', 1), contains('Format'));
      expect(Validators.documentFile('tanpa-ekstensi', 1), contains('Format'));
    });

    test('accepts files up to exactly 10 MiB', () {
      expect(
        Validators.documentFile('dokumen.pdf', Validators.maxDocumentBytes),
        isNull,
      );
    });

    test('rejects files larger than 10 MiB and empty files', () {
      expect(
        Validators.documentFile('dokumen.pdf', Validators.maxDocumentBytes + 1),
        contains('10 MB'),
      );
      expect(Validators.documentFile('dokumen.pdf', 0), contains('kosong'));
    });
  });

  group('Validators.photoFile', () {
    test('accepts JPG, JPEG, and PNG formats case-insensitively', () {
      expect(Validators.photoFile('foto.JPG', 1), isNull);
      expect(Validators.photoFile('foto.jpeg', 1), isNull);
      expect(Validators.photoFile('foto.PNG', 1), isNull);
      expect(Validators.photoFile('image', 1, mimeType: 'image/jpeg'), isNull);
    });

    test('rejects unsupported formats, empty files, and files over 3 MiB', () {
      expect(Validators.photoFile('dokumen.pdf', 1), contains('Format'));
      expect(Validators.photoFile('foto.png', 0), contains('kosong'));
      expect(
        Validators.photoFile('foto.png', Validators.maxPhotoBytes + 1),
        contains('3 MB'),
      );
    });

    test('accepts files up to exactly 3 MiB', () {
      expect(
        Validators.photoFile('foto.png', Validators.maxPhotoBytes),
        isNull,
      );
    });

    test('enforces the maximum number of photos', () {
      expect(Validators.photoCount(Validators.maxPhotoCount - 1), isNull);
      expect(
        Validators.photoCount(Validators.maxPhotoCount),
        contains('${Validators.maxPhotoCount}'),
      );
    });
  });
}
