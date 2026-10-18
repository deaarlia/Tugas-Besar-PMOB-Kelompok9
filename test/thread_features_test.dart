import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unand_space/data/thread_repository.dart';
import 'package:unand_space/models/attachments.dart';
import 'package:unand_space/models/thread_comment.dart';
import 'package:unand_space/models/user_profile.dart';
import 'package:unand_space/theme/app_theme.dart';
import 'package:unand_space/widgets/vote_control.dart';

void main() {
  final repository = ThreadRepository.instance;

  group('VoteControl', () {
    testWidgets('shows separate upvote and downvote counts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VoteControl(
              upvoteCount: 7,
              downvoteCount: 3,
              myVote: 1,
              onVote: _noOpVote,
            ),
          ),
        ),
      );

      expect(
        tester.widget<Icon>(find.byIcon(Icons.arrow_upward)).color,
        AppColors.primary,
      );
      expect(
        tester.widget<Text>(find.text('7')).style?.color,
        AppColors.primary,
      );
      expect(
        tester.widget<Text>(find.text('3')).style?.color,
        AppColors.textMuted,
      );
      expect(
        tester.widget<Icon>(find.byIcon(Icons.arrow_downward)).color,
        AppColors.textMuted,
      );
      final upvoteChip = tester.widget<Material>(
        find.byKey(const ValueKey('vote-chip-1')),
      );
      expect(upvoteChip.shape, const StadiumBorder());
      expect(upvoteChip.color, AppColors.primary.withValues(alpha: 0.14));
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('vote-chip-1')),
          matching: find.text('7'),
        ),
        findsOneWidget,
      );
      final inactiveDownvoteChip = tester.widget<Material>(
        find.byKey(const ValueKey('vote-chip--1')),
      );
      expect(inactiveDownvoteChip.color, Colors.transparent);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('vote-chip--1')),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VoteControl(
              upvoteCount: 7,
              downvoteCount: 4,
              myVote: -1,
              onVote: _noOpVote,
            ),
          ),
        ),
      );
      expect(
        tester.widget<Icon>(find.byIcon(Icons.arrow_upward)).color,
        AppColors.textMuted,
      );
      expect(
        tester.widget<Icon>(find.byIcon(Icons.arrow_downward)).color,
        AppColors.error,
      );
      expect(
        tester.widget<Text>(find.text('7')).style?.color,
        AppColors.textMuted,
      );
      expect(tester.widget<Text>(find.text('4')).style?.color, AppColors.error);
      final downvoteChip = tester.widget<Material>(
        find.byKey(const ValueKey('vote-chip--1')),
      );
      expect(downvoteChip.shape, const StadiumBorder());
      expect(downvoteChip.color, AppColors.error.withValues(alpha: 0.14));
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('vote-chip--1')),
          matching: find.text('4'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Material>(find.byKey(const ValueKey('vote-chip-1')))
            .color,
        Colors.transparent,
      );
    });
  });

  group('Thread interactions', () {
    test('comments enforce 500 characters and retain attachments', () async {
      final photo = Uint8List.fromList([1, 2, 3]);
      final document = DocumentAttachment(
        name: 'lampiran.pdf',
        bytes: Uint8List.fromList([4, 5]),
      );
      final comment = await repository.addComment(
        threadId: 'T002',
        authorName: 'Attachment test user',
        authorBadge: 'Test',
        content: 'Balasan dengan lampiran',
        photos: [photo],
        document: document,
      );
      expect(comment.photos, [photo]);
      expect(comment.document?.name, 'lampiran.pdf');

      await expectLater(
        repository.addComment(
          threadId: 'T002',
          authorName: 'Long reply test user',
          authorBadge: 'Test',
          content: '😀' * 501,
          parentId: comment.id,
        ),
        throwsA(isA<ThreadException>()),
      );
      final maxLengthReply = await repository.addComment(
        threadId: 'T002',
        authorName: 'Max length test user',
        authorBadge: 'Test',
        content: '😀' * 500,
        parentId: comment.id,
      );
      expect(maxLengthReply.content.characters.length, 500);
    });

    test(
      'votes can be changed and removed but not cast on own content',
      () async {
        final initialScore = repository.threads
            .firstWhere((thread) => thread.id == 'T001')
            .score;

        expect(
          await repository.voteThread(
            threadId: 'T001',
            userName: 'Feature test user',
            vote: 1,
          ),
          initialScore + 1,
        );
        var thread = repository.threads.firstWhere(
          (thread) => thread.id == 'T001',
        );
        expect(thread.upvoteCount, 43);
        expect(thread.downvoteCount, 0);
        expect(
          await repository.voteThread(
            threadId: 'T001',
            userName: 'Feature test user',
            vote: -1,
          ),
          initialScore - 1,
        );
        thread = repository.threads.firstWhere((thread) => thread.id == 'T001');
        expect(thread.upvoteCount, 42);
        expect(thread.downvoteCount, 1);
        expect(
          await repository.voteThread(
            threadId: 'T001',
            userName: 'Feature test user',
            vote: -1,
          ),
          initialScore,
        );
        thread = repository.threads.firstWhere((thread) => thread.id == 'T001');
        expect(thread.upvoteCount, 42);
        expect(thread.downvoteCount, 0);
        await expectLater(
          repository.voteThread(
            threadId: 'T001',
            userName: 'Rafi Kurniawan',
            vote: 1,
          ),
          throwsA(isA<ThreadException>()),
        );
      },
    );

    test('comments allow replies to five levels, but not a sixth', () async {
      final author = 'Nested comment test user';
      final chain = <ThreadComment>[
        await repository.addComment(
          threadId: 'T003',
          authorName: author,
          authorBadge: 'Test',
          content: 'Komentar utama',
        ),
      ];
      for (var depth = 1; depth < 5; depth++) {
        chain.add(
          await repository.addComment(
            threadId: 'T003',
            authorName: 'Nested user $depth',
            authorBadge: 'Test',
            content: 'Balasan tingkat ${depth + 1}',
            parentId: chain.last.id,
          ),
        );
      }

      expect(chain.map((comment) => comment.depth), [0, 1, 2, 3, 4]);
      expect(
        repository.threads.firstWhere((thread) => thread.id == 'T003').comments,
        5,
      );
      await expectLater(
        repository.addComment(
          threadId: 'T003',
          authorName: 'Another test user',
          authorBadge: 'Test',
          content: 'Balasan tingkat enam',
          parentId: chain.last.id,
        ),
        throwsA(isA<ThreadException>()),
      );

      await repository.updateComment(
        threadId: 'T003',
        commentId: chain.first.id,
        authorName: author,
        content: 'Komentar utama diedit',
      );
      await repository.deleteComment(
        threadId: 'T003',
        commentId: chain.first.id,
        authorName: author,
      );
      await repository.acceptAnswer(
        threadId: 'T003',
        commentId: chain[1].id,
        authorName: 'Aisyah Putri',
      );
      final storedComments = await repository.fetchComments('T003');
      expect(
        storedComments
            .firstWhere((comment) => comment.id == chain.first.id)
            .isDeleted,
        isTrue,
      );
      expect(
        repository.threads.firstWhere((thread) => thread.id == 'T003').comments,
        4,
      );
      expect(
        repository.threads
            .firstWhere((thread) => thread.id == 'T003')
            .acceptedCommentId,
        chain[1].id,
      );
    });

    test('threads can be edited and soft-deleted by their author', () async {
      final created = await repository.createThread(
        title: 'Utas pengujian',
        content: 'Isi untuk menguji pembaruan dan penghapusan utas.',
        topics: const [],
        photos: const [],
        author: UserProfile.demo,
        isAnonymous: false,
        community: 'Akademik',
      );
      expect(created.community, 'Akademik');

      await expectLater(
        repository.updateThread(
          threadId: created.id,
          authorName: 'Pengguna lain',
          title: 'Tidak diizinkan',
          content: created.content,
          topics: const [],
          photos: const [],
          isAnonymous: false,
          community: 'Umum',
        ),
        throwsA(isA<ThreadException>()),
      );

      final updated = await repository.updateThread(
        threadId: created.id,
        authorName: UserProfile.demo.name,
        title: 'Utas pengujian diedit',
        content: created.content,
        topics: const [],
        photos: const [],
        isAnonymous: true,
        community: 'Umum',
      );
      expect(updated.isEdited, isTrue);
      expect(updated.isAnonymous, isTrue);
      expect(updated.community, 'Umum');

      await repository.deleteThread(
        threadId: created.id,
        authorName: UserProfile.demo.name,
      );
      expect(
        repository.threads.any((thread) => thread.id == created.id),
        isFalse,
      );
    });
  });
}

void _noOpVote(int _) {}
