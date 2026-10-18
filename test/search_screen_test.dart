import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unand_space/models/user_profile.dart';
import 'package:unand_space/screens/home_screen.dart';
import 'package:unand_space/screens/search_screen.dart';

void main() {
  testWidgets('home search bar shows the full search hint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(currentUser: UserProfile.demo)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cari topik, mata kuliah, komunitas...'), findsOneWidget);
    await tester.tap(find.text('Cari topik, mata kuliah, komunitas...'));
    await tester.pumpAndSettle();
    expect(find.text('Pencarian'), findsOneWidget);
  });

  testWidgets('shows keyword suggestions before a search', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchScreen(currentUser: UserProfile.demo)),
    );

    expect(find.text('Temukan percakapan'), findsOneWidget);
    expect(find.text('Skripsi'), findsOneWidget);
    expect(find.text('Beasiswa'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Temukan percakapan')).style?.fontSize,
      14.5,
    );
  });

  testWidgets('keyword recommendation opens matching thread results', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchScreen(currentUser: UserProfile.demo)),
    );

    await tester.tap(find.text('Skripsi'));
    await tester.pumpAndSettle();

    expect(find.text('Temukan percakapan'), findsNothing);
    expect(
      find.text(
        'Adakah Rekomendasi Dosen Pembimbing untuk Skripsi Machine Learning di Teknik Komputer?',
      ),
      findsOneWidget,
    );
  });
}
