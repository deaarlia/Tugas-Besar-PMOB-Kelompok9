import 'package:flutter/foundation.dart';

class TopicDialogViewModel extends ChangeNotifier {
  TopicDialogViewModel({required this.existing});

  final List<String> existing;
  String? _error;

  String? get error => _error;

  String? validate(String input) {
    final value = input.replaceAll('#', '').replaceAll(RegExp(r'\s+'), '');
    if (value.isEmpty) {
      _error = 'Topik tidak boleh kosong';
    } else if (existing.any(
      (topic) => topic.toLowerCase() == value.toLowerCase(),
    )) {
      _error = 'Topik sudah ditambahkan';
    } else {
      _error = null;
      return value;
    }
    notifyListeners();
    return null;
  }
}
