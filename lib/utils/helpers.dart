import 'package:flutter/material.dart';

/// Snackbar untuk bagian UI yang sengaja belum berfungsi (milik Modul lain).
void showComingSoon(BuildContext context, [String feature = 'Fitur ini']) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$feature dikerjakan di modul lain')));
}

const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Contoh: "14 Okt 2026, 13.48".
String formatDateTime(DateTime d) {
  final String hh = d.hour.toString().padLeft(2, '0');
  final String mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${_months[d.month - 1]} ${d.year}, $hh.$mm';
}