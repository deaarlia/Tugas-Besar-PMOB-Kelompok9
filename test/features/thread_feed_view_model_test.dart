import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_pmob/data/placeholder_data.dart';
import 'package:tugas_pmob/models/thread_sort.dart';
import 'package:tugas_pmob/repositories/thread_repository.dart';
import 'package:tugas_pmob/viewmodels/thread_feed_view_model.dart';

void main() {
  late ThreadFeedViewModel vm;

  setUp(() => vm = ThreadFeedViewModel(const InMemoryThreadRepository()));

  test('default: terbaru, thread-1 dan thread-2 teratas', () {
    final ids = vm.visibleThreads.map((p) => p.id).toList();
    expect(ids.take(2), ['thread-1', 'thread-2']);
    expect(ids.length, demoPosts.length);
  });

  test('cari tidak peduli huruf besar/kecil dan mengabaikan **', () {
    vm.setQuery('krs basis');
    expect(vm.visibleThreads.map((p) => p.id), ['thread-3']);
  });

  test('semua kata harus ada di judul atau isi', () {
    vm.setQuery('krs beasiswa');
    expect(vm.visibleThreads, isEmpty);
  });

  test('filter komunitas', () {
    vm.selectCommunity(kCommunityBem);
    expect(vm.visibleThreads.every((p) => p.communityId == kCommunityBem),
        isTrue);
    expect(vm.visibleThreads.length, 2);
  });

  test('terpopuler: skor, lalu komentar, lalu terbaru', () {
    vm.selectSort(ThreadSort.popular);
    final ids = vm.visibleThreads.map((p) => p.id).toList();
    expect(ids.first, 'thread-2'); // 120 suara, 45 komentar
    expect(ids[1], 'thread-7'); // 120 suara, 22 komentar
  });

    test('belum terjawab hanya berisi utas tanpa komentar sama sekali', () {
    vm.selectSort(ThreadSort.unanswered);
    final ids = vm.visibleThreads.map((p) => p.id).toList();
    expect(vm.visibleThreads.every((p) => p.comments == 0), isTrue);
    expect(ids, ['thread-4', 'thread-6']); // urut terbaru
  });

  test('resetFilters mengembalikan kondisi awal', () {
    vm.setQuery('kos');
    vm.selectCommunity(kCommunityUmum);
    vm.selectSort(ThreadSort.popular);
    vm.resetFilters();
    expect(vm.hasActiveFilters, isFalse);
  });
}
