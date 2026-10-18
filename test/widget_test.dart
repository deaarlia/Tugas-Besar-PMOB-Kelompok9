import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_pmob/main.dart';
import 'package:tugas_pmob/screens/login_page.dart'; // <-- Tambahkan import ini

void main() {
  testWidgets('UnandSpaceApp initial render test', (WidgetTester tester) async {
    // 1. Build aplikasi dan jalankan frame pertama
    await tester.pumpWidget(const UnandSpaceApp());

    // 2. Pastikan MaterialApp berhasil dimuat di hierarki teratas
    expect(find.byType(MaterialApp), findsOneWidget);

    // 3. Verifikasi apakah halaman awal (halaman login) muncul dengan benar
    expect(find.byType(UnandspaceCampusAuthentication), findsOneWidget);
  });
}