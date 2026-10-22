// lib/viewmodels/reports_provider.dart
import 'package:flutter/foundation.dart';
import 'package:unand_space/models/report.dart';
import 'package:unand_space/repositories/community_repository.dart';

class ReportsProvider extends ChangeNotifier {
  ReportsProvider({required this.repository, required this.communityId}) {
    load();
  }

  final CommunityRepository repository;
  final String communityId;

  List<Report> reports = const [];
  ReportStatus filter = ReportStatus.pending;
  bool isLoading = true;
  bool isBusy = false;
  String? loadError;
  String? actionError;
  bool _disposed = false;

  List<Report> get visible => reports.where((r) => r.status == filter).toList();

  int countOf(ReportStatus s) => reports.where((r) => r.status == s).length;

  Report? byId(String id) {
    for (final r in reports) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  void setFilter(ReportStatus s) {
    filter = s;
    notifyListeners();
  }

  Future<void> load() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      reports = await repository.listReports(communityId);
    } catch (_) {
      loadError = 'Gagal memuat laporan.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reject(String reportId) => _act(
    () => repository.rejectReport(communityId, reportId),
    'Gagal menolak laporan. Coba lagi.',
  );

  Future<bool> deleteContent(String reportId) => _act(
    () => repository.deleteReportedContent(communityId, reportId),
    'Gagal menghapus konten. Coba lagi.',
  );

  Future<bool> _act(Future<void> Function() action, String fallback) async {
    actionError = null;
    isBusy = true;
    notifyListeners();
    try {
      await action();
      reports = await repository.listReports(communityId);
      return true;
    } on RepositoryException catch (e) {
      actionError = e.message;
      return false;
    } catch (_) {
      actionError = fallback;
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
