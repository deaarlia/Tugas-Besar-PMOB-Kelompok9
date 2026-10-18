import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

ImageProvider? imageProviderFor(String? src) {
  if (src == null || src.isEmpty) return null;
  if (kIsWeb || src.startsWith('http')) return NetworkImage(src);
  return FileImage(File(src));
}
