import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_pmob/main.dart';
import 'package:tugas_pmob/models/report_reason.dart';
import 'package:tugas_pmob/models/report_target.dart';
import 'package:tugas_pmob/viewmodels/report_form_view_model.dart';
import 'package:tugas_pmob/repositories/report_repository.dart';
import 'package:tugas_pmob/screens/report_form_screen.dart';
import 'package:tugas_pmob/screens/thread_detail_screen.dart';

const ReportTarget _target = ReportTarget(
  type: ReportTargetType.thread,
  id: 't-1',
  authorName: 'Tester',
  excerpt: 'Judul uji',
);

void main() {
  group('ReportFormViewModel (validation)', () {
    late ReportFormViewModel form;

    setUp(() {
      form = ReportFormViewModel(
        repository: InMemoryReportRepository(latency: Duration.zero),
        target: _target,
      );
    });

    test('alasan wajib dipilih', () async {
      expect(await form.submit(), isNull);
      expect(form.reasonError, 'Pilih salah satu alasan laporan');
    });

    test('keterangan wajib jika alasan Lainnya', () async {
      form.selectReason(ReportReason.lainnya);
      expect(await form.submit(), isNull);
      expect(form.descriptionError, isNotNull);
    });

    test('keterangan maksimal 300 karakter', () async {
      form.selectReason(ReportReason.spam);
      form.setDescription('a' * 301);
      expect(await form.submit(), isNull);
      expect(form.descriptionError, 'Keterangan maksimal 300 karakter');
    });

    test('laporan valid berstatus Menunggu, laporan ganda ditolak', () async {
      form.selectReason(ReportReason.hoaks);
      final report = await form.submit();
      expect(report, isNotNull);
      expect(report!.status.label, 'Menunggu');

      expect(await form.submit(), isNull);
      expect(form.formError, const DuplicateReportException().message);
    });

    test(
      'setDescription selalu memberi tahu pendengar (penghitung karakter)',
      () {
        int notified = 0;
        form.addListener(() => notified++);

        form.setDescription('abc');
        form.setDescription('abcd');

        expect(notified, 2);
        expect(form.description.length, 4);
      },
    );
  });

  group('Workflow Laporkan Konten (UI)', () {
    Future<void> setUpApp(WidgetTester tester) async {
      tester.view.physicalSize = const Size(540, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UnandSpaceApp(
          repository: InMemoryReportRepository(
            latency: Duration.zero,
            seedDemoData: false,
          ),
        ),
      );
    }

    /// Beranda: titik tiga di kartu utas pertama -> Laporkan Postingan.
    Future<void> openFormFromHome(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Laporkan Utas'));
      await tester.pumpAndSettle();
    }

    Future<void> pickReason(WidgetTester tester, String label) async {
      final Finder tile = find.text(label);
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }

    Future<void> tapSend(WidgetTester tester) async {
      final Finder send = find.text('Kirim Laporan');
      await tester.ensureVisible(send);
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pumpAndSettle();
    }

    /// Layar "Status Laporan" -> tombol "Selesai & Kembali".
    Future<void> finishSuccessScreen(WidgetTester tester) async {
      expect(find.text('Laporan Berhasil Terkirim'), findsOneWidget);
      final Finder done = find.text('Selesai & Kembali');
      await tester.ensureVisible(done);
      await tester.pumpAndSettle();
      await tester.tap(done);
      await tester.pumpAndSettle();
    }

    testWidgets('input tidak valid: error tampil dan tetap di form', (
      WidgetTester tester,
    ) async {
      await setUpApp(tester);
      await openFormFromHome(tester);

      await tapSend(tester);
      expect(find.text('Pilih salah satu alasan laporan'), findsOneWidget);

      await pickReason(tester, 'Lainnya');
      await tapSend(tester);
      expect(
        find.text('Keterangan wajib diisi jika alasan "Lainnya"'),
        findsOneWidget,
      );
      expect(find.byType(ReportFormScreen), findsOneWidget); // masih di form
    });

    testWidgets('penghitung karakter ikut berubah saat mengetik', (
      WidgetTester tester,
    ) async {
      await setUpApp(tester);
      await openFormFromHome(tester);

      expect(find.text('0/300'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.text('3/300'), findsOneWidget);
    });

    testWidgets('berhasil dari Beranda: status laporan, lalu snackbar', (
      WidgetTester tester,
    ) async {
      await setUpApp(tester);
      await openFormFromHome(tester);

      await pickReason(tester, 'Pesan Spam / Penipuan');
      await tapSend(tester);
      await finishSuccessScreen(tester);

      expect(find.text('Laporan berhasil dikirim'), findsOneWidget);
      expect(find.byType(ReportFormScreen), findsNothing);
    });

    testWidgets('berhasil dari halaman utas: kembali ke utas + snackbar', (
      WidgetTester tester,
    ) async {
      await setUpApp(tester);

      await tester.tap(find.textContaining('Rekomendasi Dosen Pembimbing'));
      await tester.pumpAndSettle();
      expect(find.byType(ThreadDetailScreen), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.more_vert),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Laporkan Utas'));
      await tester.pumpAndSettle();

      await pickReason(tester, 'Pesan Spam / Penipuan');
      await tapSend(tester);
      await finishSuccessScreen(tester);

      expect(find.byType(ReportFormScreen), findsNothing);
      expect(
        find.byType(ThreadDetailScreen),
        findsOneWidget,
      ); // kembali ke utas
      expect(find.text('Laporan berhasil dikirim'), findsOneWidget);
    });

    testWidgets('laporan baru tampil di Laporan Saya: Dalam Peninjauan', (
      WidgetTester tester,
    ) async {
      await setUpApp(tester);
      await openFormFromHome(tester);

      await pickReason(tester, 'Pesan Spam / Penipuan');
      await tapSend(tester);
      await finishSuccessScreen(tester);

      await tester.tap(find.text('Lihat')); // aksi pada snackbar
      await tester.pumpAndSettle();

      expect(find.text('Dalam Peninjauan'), findsOneWidget);
      expect(find.text("Utas di Forum FTI '22"), findsOneWidget);
      expect(find.text('Pesan Spam'), findsOneWidget);
      expect(find.text('Kerahasiaan Terjamin'), findsOneWidget);
    });

    testWidgets('konten yang sama tidak bisa dilaporkan dua kali', (
      WidgetTester tester,
    ) async {
      await setUpApp(tester);

      await openFormFromHome(tester);
      await pickReason(tester, 'Pesan Spam / Penipuan');
      await tapSend(tester);
      await finishSuccessScreen(tester);

      await openFormFromHome(tester);
      await pickReason(tester, 'Informasi Palsu / Hoaks Seputar Akademik');
      await tapSend(tester);

      expect(
        find.text('Kamu sudah melaporkan konten ini sebelumnya.'),
        findsOneWidget,
      );
      expect(find.byType(ReportFormScreen), findsOneWidget); // masih di form
    });

    testWidgets('Profil tidak lagi menampilkan Poin Reputasi', (
      WidgetTester tester,
    ) async {
      await setUpApp(tester);

      await tester.tap(find.text('Profil').first);
      await tester.pumpAndSettle();

      expect(find.text('Poin Reputasi'), findsNothing);
      expect(find.text('Laporan Saya'), findsOneWidget);
    });
  });
}
