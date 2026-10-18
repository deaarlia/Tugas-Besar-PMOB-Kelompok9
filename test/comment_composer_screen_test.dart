import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unand_space/screens/comment_composer_screen.dart';

void main() {
  testWidgets('expanded reply composer caps text at 500 characters', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CommentComposerScreen(
          replyingTo: 'Aisyah',
          initialContent: '',
          onSubmit: ({
            required content,
            required photos,
            required document,
          }) async => null,
        ),
      ),
    );

    expect(find.text('Membalas Aisyah'), findsOneWidget);
    expect(find.byTooltip('Pilih foto'), findsOneWidget);
    expect(find.byTooltip('Lampirkan file'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'x' * 501);
    await tester.pump();

    expect(find.text('500/500'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text.length,
      500,
    );
  });
}
