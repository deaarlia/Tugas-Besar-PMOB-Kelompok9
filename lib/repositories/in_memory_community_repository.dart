// lib/repositories/in_memory_community_repository.dart
import 'package:tugas_pmob/models/community.dart';
import 'package:tugas_pmob/models/report.dart';
import 'package:tugas_pmob/models/thread_post.dart';
import 'package:tugas_pmob/repositories/community_repository.dart';
import 'package:unand_space/models/community.dart';
import 'package:unand_space/repositories/community_repository.dart';


/// Hanya untuk menguji UI. Ganti dengan implementasi REST API nanti.
class InMemoryCommunityRepository implements CommunityRepository {
  final List<Community> _items = [];
  final Map<String, List<Moderator>> _moderators = {};
  final Map<String, List<ThreadPost>> _threads = {};
  final Map<String, List<Report>> _reports = {};
  int _seq = 0;
  int _modSeq = 0;
  int _threadSeq = 0;
  int _reportSeq = 0;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<Community>> list() async {
    await _delay();
    return List.unmodifiable(_items.reversed); // terbaru di atas
  }

  @override
  Future<bool> isNameTaken(String name, {String? excludeId}) async {
    await _delay();
    return _items.any(
      (c) => c.id != excludeId && c.name.toLowerCase() == name.toLowerCase(),
    );
  }

  @override
  Future<Community> create(CommunityDraft draft) async {
    await _delay();
    final c = Community(
      id: 'c${++_seq}',
      name: draft.name,
      description: draft.description,
      category: draft.category,
      isPublic: draft.isPublic,
      iconUrl: draft.iconPath,
      coverUrl: draft.coverPath,
      rules: draft.rules,
      createdAt: DateTime.now(),
      creatorName: 'Anda', // placeholder: seharusnya dari data pengguna login
      memberCount: 1, // pembuat otomatis menjadi anggota
      myRole: CommunityRole.creator,
    );
    _items.add(c);
    _moderators[c.id] = [
      Moderator(id: 'm${++_modSeq}', name: c.creatorName!, isCreator: true),
    ];
    _seed(c);
    return c;
  }

  @override
  Future<Community> update(String id, CommunityDraft draft) async {
    await _delay();
    final i = _items.indexWhere((c) => c.id == id);
    final old = _items[i];
    final c = Community(
      id: id,
      name: draft.name,
      description: draft.description,
      category: draft.category,
      isPublic: draft.isPublic,
      iconUrl: draft.iconPath ?? old.iconUrl,
      coverUrl: draft.coverPath ?? old.coverUrl,
      rules: old.rules,
      createdAt: old.createdAt,
      creatorName: old.creatorName,
      memberCount: old.memberCount,
      myRole: old.myRole,
    );
    _items[i] = c;
    return c;
  }

  @override
  Future<void> delete(String id) async {
    await _delay();
    _items.removeWhere((c) => c.id == id);
    _moderators.remove(id);
    _threads.remove(id);
    _reports.remove(id);
  }

  // ---- FR-09 ----

  @override
  Future<Community> updateRules(String id, String rules) async {
    await _delay();
    final i = _items.indexWhere((c) => c.id == id);
    final old = _items[i];
    final c = Community(
      id: old.id,
      name: old.name,
      description: old.description,
      category: old.category,
      isPublic: old.isPublic,
      iconUrl: old.iconUrl,
      coverUrl: old.coverUrl,
      rules: rules,
      createdAt: old.createdAt,
      creatorName: old.creatorName,
      memberCount: old.memberCount,
      myRole: old.myRole,
    );
    _items[i] = c;
    return c;
  }

  @override
  Future<List<Moderator>> listModerators(String communityId) async {
    await _delay();
    return List.unmodifiable(_moderators[communityId] ?? const []);
  }

  @override
  Future<Moderator> appointModerator(
    String communityId,
    String identifier,
  ) async {
    await _delay();
    final list = _moderators.putIfAbsent(communityId, () => []);
    final exists = list.any(
      (m) => m.name.toLowerCase() == identifier.toLowerCase(),
    );
    if (exists) {
      throw const RepositoryException('Pengguna ini sudah menjadi moderator');
    }
    // Placeholder: backend asli harus mencari pengguna dan menolak jika tidak ditemukan.
    final m = Moderator(id: 'm${++_modSeq}', name: identifier);
    list.add(m);
    return m;
  }

  @override
  Future<void> revokeModerator(String communityId, String moderatorId) async {
    await _delay();
    final list = _moderators[communityId] ?? [];
    final target = list.where((m) => m.id == moderatorId);
    if (target.isEmpty) {
      throw const RepositoryException('Moderator tidak ditemukan');
    }
    if (target.first.isCreator) {
      throw const RepositoryException('Pembuat komunitas tidak dapat dicabut');
    }
    list.removeWhere((m) => m.id == moderatorId);
  }

  // ---- FR-10 ----

  @override
  Future<List<ThreadPost>> listThreads(String communityId) async {
    await _delay();
    final list = [...(_threads[communityId] ?? <ThreadPost>[])];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> pinThread(String communityId, String threadId) async {
    await _delay();
    final list = _threads[communityId] ?? [];
    final i = list.indexWhere((t) => t.id == threadId);
    if (i < 0) throw const RepositoryException('Utas tidak ditemukan');
    // Hanya satu utas tersemat: yang lama dilepas.
    for (var j = 0; j < list.length; j++) {
      if (list[j].isPinned) list[j] = list[j].withPinned(false);
    }
    list[i] = list[i].withPinned(true);
  }

  @override
  Future<void> unpinThread(String communityId, String threadId) async {
    await _delay();
    final list = _threads[communityId] ?? [];
    final i = list.indexWhere((t) => t.id == threadId);
    if (i < 0) throw const RepositoryException('Utas tidak ditemukan');
    list[i] = list[i].withPinned(false);
  }

  // ---- FR-11 ----

  @override
  Future<List<Report>> listReports(String communityId) async {
    await _delay();
    final list = [...(_reports[communityId] ?? <Report>[])];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> rejectReport(String communityId, String reportId) async {
    await _delay();
    final list = _reports[communityId] ?? [];
    final i = list.indexWhere((r) => r.id == reportId);
    if (i < 0) throw const RepositoryException('Laporan tidak ditemukan');
    if (list[i].status != ReportStatus.pending) {
      throw const RepositoryException('Laporan ini sudah diproses');
    }
    list[i] = list[i].copyWith(status: ReportStatus.rejected);
  }

  @override
  Future<void> deleteReportedContent(
    String communityId,
    String reportId,
  ) async {
    await _delay();
    final list = _reports[communityId] ?? [];
    final i = list.indexWhere((r) => r.id == reportId);
    if (i < 0) throw const RepositoryException('Laporan tidak ditemukan');
    final r = list[i];
    if (r.status != ReportStatus.pending) {
      throw const RepositoryException('Laporan ini sudah diproses');
    }
    if (r.contentType == ReportContentType.thread && r.contentId != null) {
      _threads[communityId]?.removeWhere((t) => t.id == r.contentId);
    }
    list[i] = r.copyWith(status: ReportStatus.deleted);
  }

  // ---- DATA UJI SEMENTARA (hapus setelah modul utas dan laporan tersedia) ----

  void _seed(Community c) {
    final now = DateTime.now();

    ThreadPost thread(
      String author,
      String body,
      Duration ago, {
      bool anon = false,
      int up = 0,
      int cm = 0,
    }) {
      return ThreadPost(
        id: 't${++_threadSeq}',
        communityId: c.id,
        authorName: author,
        isAnonymous: anon,
        body: body,
        createdAt: now.subtract(ago),
        upvotes: up,
        commentCount: cm,
      );
    }

    final annisa = thread(
      'Annisa Putri',
      'Info Open Recruitment Kepanitiaan IS FAIR (Information System Fair) 2025 resmi dibuka! Ada 12 divisi mulai dari Acara, Humas, hingga IT & Desain.',
      const Duration(hours: 6),
      up: 35,
      cm: 8,
    );
    final tips = thread(
      'Mahasiswa Anonim',
      'Boleh minta tips dan pandangan dari kating mengenai peminatan Enterprise System di semester 5? Lebih prospek fokus ke ERP/SAP atau ke arah IT Governance & Risk Management untuk peluang magang BUMN/swasta?',
      const Duration(hours: 5),
      anon: true,
      up: 68,
      cm: 24,
    );
    final dekanat = thread(
      'Rafly Pratama',
      'Pengumuman resmi dari dekanat: seluruh perkuliahan semester depan ditiadakan dan diganti dengan program magang penuh di industri tanpa perlu konversi SKS secara manual di portal akademik. Harap segera hubungi ketua jurusan masing-masing.',
      const Duration(hours: 4),
      up: 42,
      cm: 12,
    );
    final maba = thread(
      'Mahasiswa Anonim',
      'Maba angkatan 24 di jurusan ini sombong banget, mending kita kerjain bareng-bareng di grup sampai mereka keluar.',
      const Duration(days: 1, hours: 3),
      anon: true,
      up: 5,
      cm: 2,
    );
    _threads[c.id] = [annisa, tips, dekanat, maba];

    var code = 101;
    Report report({
      required ReportContentType type,
      required String text,
      required String author,
      required Duration postedAgo,
      required Duration reportedAgo,
      required ReportReason reason,
      required String note,
      String? contentId,
      int up = 0,
      int cm = 0,
    }) {
      return Report(
        id: 'r${++_reportSeq}',
        code: '#REP-${++code}',
        contentType: type,
        contentId: contentId,
        contentText: text,
        contentAuthor: author,
        contentPostedAt: now.subtract(postedAgo),
        upvotes: up,
        commentCount: cm,
        reason: reason,
        reporterNote: note,
        createdAt: now.subtract(reportedAgo),
      );
    }

    _reports[c.id] = [
      report(
        type: ReportContentType.thread,
        contentId: maba.id,
        text: maba.body,
        author: maba.displayAuthor,
        postedAgo: const Duration(days: 1, hours: 3),
        reportedAgo: const Duration(days: 1),
        reason: ReportReason.harassment,
        note: 'Utas ini mengajak merundung mahasiswa baru.',
        up: maba.upvotes,
        cm: maba.commentCount,
      ),
      report(
        type: ReportContentType.comment,
        text: 'PROMO JOKI TUGAS AKHIR DAN SKRIPSI BERGARANSI 100% LULUS CEPAT, HUBUNGI WA KAMI SEKARANG',
        author: 'Dimas Aditya',
        postedAgo: const Duration(hours: 5),
        reportedAgo: const Duration(hours: 4),
        reason: ReportReason.spam,
        note: 'Komentar ini berisi promosi joki tugas yang melanggar aturan komunitas.',
      ),
      report(
        type: ReportContentType.thread,
        contentId: dekanat.id,
        text: dekanat.body,
        author: dekanat.displayAuthor,
        postedAgo: const Duration(hours: 4),
        reportedAgo: const Duration(hours: 2),
        reason: ReportReason.hoax,
        note: 'Informasi jadwal ini tidak sesuai pengumuman resmi fakultas. Dekanat belum pernah mengeluarkan edaran tersebut dan memicu kepanikan mahasiswa angkatan 22 dan 23.',
        up: dekanat.upvotes,
        cm: dekanat.commentCount,
      ),
    ];
  }
}
