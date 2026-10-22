import 'package:flutter/material.dart';

import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../screens/community/community_explore_screen.dart';
import '../screens/create_thread_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String communities = '/communities';
  static const String createThread = '/create-thread';
  static const String profile = '/profile';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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
      default:
        return null; // -> onUnknownRoute
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _errorRoute<void>(
      settings,
      'Halaman yang kamu tuju belum tersedia.',
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
