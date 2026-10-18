// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:unand_space/main.dart';
import 'package:unand_space/screens/home_screen.dart';

void main() {
  testWidgets('App starts on the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const UnandSpaceApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Bottom navigation opens community explore', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UnandSpaceApp());
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Komunitas').last);
    await tester.pumpAndSettle();

    expect(find.text('Jelajah Komunitas'), findsOneWidget);
    expect(find.text('Buat'), findsOneWidget);
  });
}
