import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import package provider

// Import model dan repository
import 'package:tugas_pmob/models/item.dart';
import 'package:tugas_pmob/viewmodels/community_list_view_model.dart';
import 'package:tugas_pmob/viewmodels/my_reports_view_model.dart';
import 'package:tugas_pmob/viewmodels/thread_feed_view_model.dart';
import 'package:tugas_pmob/repositories/community_repository.dart';
import 'package:tugas_pmob/repositories/report_repository.dart';
import 'package:tugas_pmob/repositories/thread_repository.dart';
import 'package:tugas_pmob/viewmodels/notification_view_model.dart';
import 'package:tugas_pmob/viewmodels/profile_view_model.dart';

// Import screens
import 'package:tugas_pmob/screens/catatan_form_screen.dart';
import 'package:tugas_pmob/screens/detail_screen.dart';
import 'package:tugas_pmob/screens/login_page.dart';
import 'package:tugas_pmob/screens/main_shell.dart';
import 'package:tugas_pmob/screens/not_found_screen.dart';

void main() {
  runApp(const UnandSpaceApp());
}

class UnandSpaceApp extends StatelessWidget {
  final ReportRepository? repository;

  const UnandSpaceApp({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Daftarkan ReportRepository di level atas
        Provider<ReportRepository>(
          create: (_) => repository ?? InMemoryReportRepository(),
        ),

        // 2. Daftarkan CommunityRepository untuk FR-01 (Jelajah Komunitas)
        Provider<CommunityRepository>(
          create: (_) => InMemoryCommunityRepository(),
        ),

        // 3. Daftarkan MyReportsViewModel di bawah ReportRepository
        ChangeNotifierProvider<MyReportsViewModel>(
          create: (context) => MyReportsViewModel(
            context.read<ReportRepository>(),
          ),
        ),

        // 4. Daftarkan CommunityListViewModel di bawah CommunityRepository
        ChangeNotifierProvider<CommunityListViewModel>(
          create: (context) => CommunityListViewModel(
            context.read<CommunityRepository>(),
          )..fetchCommunities(),
        ),

        // 5. FR-03: Cari, filter komunitas, dan urutan utas di Beranda
        Provider<ThreadRepository>(
          create: (_) => const InMemoryThreadRepository(),
        ),
        ChangeNotifierProvider<ThreadFeedViewModel>(
          create: (context) =>
              ThreadFeedViewModel(context.read<ThreadRepository>()),
        ),

        // 6. NotificationViewModel (data notifikasi dummy)
        ChangeNotifierProvider<NotificationViewModel>(
          create: (_) => NotificationViewModel(),
        ),

        // 7. ProfileViewModel (data profil pengguna)
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => ProfileViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Unand Space',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
  }
}

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';
  static const String communityExplore = '/community-explore'; // Route untuk FR-01
  static const String notification = '/notifikasi';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const UnandspaceCampusAuthentication(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const MainShell(),
          settings: settings,
        );
      case detail:
        final args = settings.arguments;
        if (args is Item) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(item: args),
            settings: settings,
          );
        }
        return null; // data salah/kosong -> halaman 404
      case catatanForm:
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null; // route tidak terdaftar -> halaman 404
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}