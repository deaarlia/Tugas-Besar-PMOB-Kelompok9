import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/community/community_explore_screen.dart';
import '../screens/create_thread_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_page.dart';
import '../screens/not_found_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String communities = '/communities';
  static const String createThread = '/create-thread';
  static const String profile = '/profile';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const UnandspaceCampusAuthentication(),
          settings: settings,
        );
      case communities:
        return MaterialPageRoute<void>(
          builder: (_) => const CommunityExploreScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(currentUser: UserProfile.demo),
          settings: settings,
        );
      case profile:
        final args = settings.arguments;
        if (args is UserProfile) {
          return MaterialPageRoute<void>(
            builder: (_) => ProfileScreen(currentUser: args),
            settings: settings,
          );
        }
        return _errorRoute<void>(
          settings,
          'Data pengguna tidak dikirim ke profil.',
        );
      case createThread:
        // Argument WAJIB UserProfile -> cek tipenya dulu
        final args = settings.arguments;
        if (args is UserProfile) {
          // <ThreadPost> = tipe data yang DIKEMBALIKAN saat pop
          return MaterialPageRoute<ThreadPost>(
            builder: (_) => CreateThreadScreen(author: args),
            settings: settings,
          );
        }
        return _errorRoute<ThreadPost>(
          settings,
          'Data pengguna tidak dikirim ke form utas.',
        );
      case detail:
        final args = settings.arguments;
        if (args is Item) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(item: args),
            settings: settings,
          );
        }
        return null; // data kosong -> onUnknownRoute
      case catatanForm:
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null; // -> onUnknownRoute
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }

  static Route<T> _errorRoute<T>(RouteSettings settings, String message) {
    return MaterialPageRoute<T>(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 72),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
