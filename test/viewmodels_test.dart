import 'package:flutter_test/flutter_test.dart';
import 'package:unand_space/data/thread_repository.dart';
import 'package:unand_space/models/user_profile.dart';
import 'package:unand_space/viewmodels/create_thread_view_model.dart';
import 'package:unand_space/viewmodels/home_view_model.dart';
import 'package:unand_space/viewmodels/thread_detail_view_model.dart';
import 'package:unand_space/viewmodels/topic_dialog_view_model.dart';

void main() {
  group('HomeViewModel', () {
    test('loads threads and filters followed authors', () async {
      final viewModel = HomeViewModel();
      addTearDown(viewModel.dispose);

      await viewModel.loadThreads();
      expect(viewModel.status, ViewStatus.success);
      expect(viewModel.visibleThreads, isNotEmpty);

      viewModel.toggleFollow('Rafi Kurniawan');
      viewModel.selectTab(1);
      expect(viewModel.visibleThreads.map((thread) => thread.authorName), [
        'Rafi Kurniawan',
      ]);
    });

    test('applies search text and empty-state message', () async {
      final viewModel = HomeViewModel();
      addTearDown(viewModel.dispose);

      await viewModel.loadThreads();
      viewModel.setQuery('not found');
      expect(viewModel.visibleThreads, isEmpty);
      expect(
        viewModel.emptyMessage,
        'Tidak ada utas yang cocok dengan "not found".',
      );
    });
  });

  group('CreateThreadViewModel', () {
    test('tracks post readiness and topics', () {
      final viewModel = CreateThreadViewModel(author: UserProfile.demo);
      addTearDown(viewModel.dispose);

      expect(viewModel.canPost, isFalse);
      viewModel.titleController.text = 'Judul utas';
      viewModel.contentController.text = 'Isi utas yang cukup panjang.';
      expect(viewModel.canPost, isTrue);

      expect(viewModel.addTopic('Flutter'), isNull);
      expect(viewModel.topics, ['Flutter']);
      viewModel.removeTopic('Flutter');
      expect(viewModel.topics, isEmpty);
    });

    test('creates a thread in the default community', () async {
      final viewModel = CreateThreadViewModel(author: UserProfile.demo);
      addTearDown(viewModel.dispose);
      viewModel.titleController.text = 'Utas komunitas default';
      viewModel.contentController.text = 'Isi utas untuk pengujian komunitas.';

      final thread = await viewModel.submit();

      expect(thread?.community, 'Umum');
      if (thread != null) {
        await ThreadRepository.instance.deleteThread(
          threadId: thread.id,
          authorName: UserProfile.demo.name,
        );
      }
    });
  });

  group('TopicDialogViewModel', () {
    test('normalizes a topic and rejects duplicates or empty input', () {
      final viewModel = TopicDialogViewModel(existing: ['Flutter']);
      addTearDown(viewModel.dispose);

      expect(viewModel.validate(' #Dart '), 'Dart');
      expect(viewModel.validate(' FLUTTER '), isNull);
      expect(viewModel.error, 'Topik sudah ditambahkan');
      expect(viewModel.validate('###'), isNull);
      expect(viewModel.error, 'Topik tidak boleh kosong');
    });
  });

  test('ThreadDetailViewModel updates follow state and callback', () {
    var callbackCount = 0;
    final viewModel = ThreadDetailViewModel(
      isFollowed: false,
      onToggleFollow: () => callbackCount++,
    );
    addTearDown(viewModel.dispose);

    viewModel.toggleFollow();

    expect(viewModel.isFollowed, isTrue);
    expect(callbackCount, 1);
  });
}
