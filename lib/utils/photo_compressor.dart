import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'validators.dart';

Future<Uint8List> compressPhoto(Uint8List bytes) {
  return compute(_compressPhoto, bytes);
}

Uint8List _compressPhoto(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('Data foto tidak dapat dibaca.');
  }

  var current = img.bakeOrientation(decoded);
  const qualities = [85, 75, 65, 55, 45, 35];

  while (true) {
    for (final quality in qualities) {
      final compressed = img.encodeJpg(current, quality: quality);
      if (compressed.length <= Validators.maxPhotoBytes) {
        return Uint8List.fromList(compressed);
      }
    }

    if (current.width <= 320 && current.height <= 320) {
      throw StateError('Foto tidak dapat dikompresi hingga batas ukuran.');
    }

    final scale = current.width >= current.height
        ? 320 / current.width
        : 320 / current.height;
    current = img.copyResize(
      current,
      width: (current.width * scale).round(),
      height: (current.height * scale).round(),
    );
  }
}
