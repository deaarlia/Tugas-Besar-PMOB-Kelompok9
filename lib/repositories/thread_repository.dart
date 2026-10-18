import '../data/placeholder_data.dart';

abstract class ThreadRepository {
  List<DemoPost> getThreads();
}

/// Sumber data sementara. Ganti dengan implementasi REST API nanti.
class InMemoryThreadRepository implements ThreadRepository {
  const InMemoryThreadRepository();

  @override
  List<DemoPost> getThreads() => demoPosts;
}