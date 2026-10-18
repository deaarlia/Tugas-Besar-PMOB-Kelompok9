import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:unand_space/utils/photo_compressor.dart';
import 'package:unand_space/utils/validators.dart';

void main() {
  test('compresses a large photo within the attachment size limit', () async {
    final image = img.Image(width: 2048, height: 2048);
    var state = 1;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        state = (state * 1664525 + 1013904223) & 0xFFFFFFFF;
        image.setPixelRgba(
          x,
          y,
          (state >> 16) & 0xFF,
          (state >> 8) & 0xFF,
          state & 0xFF,
          255,
        );
      }
    }
    final source = Uint8List.fromList(img.encodePng(image));

    final compressed = await compressPhoto(source);

    expect(compressed.length, lessThanOrEqualTo(Validators.maxPhotoBytes));
    expect(img.decodeJpg(compressed), isNotNull);
  });
}
