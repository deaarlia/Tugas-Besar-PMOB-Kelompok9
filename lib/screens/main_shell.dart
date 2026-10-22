import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/notification_view_model.dart';
import 'community_explore_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

/// Shell utama yang menyimpan bottom nav + FAB secara persistent.
/// Gunakan [IndexedStack] agar state tiap tab tidak hilang saat pindah tab.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  static const List<Widget> _pages = <Widget>[
    HomeBody(),           // index 0 – Beranda
    CommunityExploreScreen(), // index 1 – Komunitas
    NotificationScreen(), // index 2 – Notifikasi
    ProfileScreen(),      // index 3 – Profil
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: _currentIndex < 2
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () {},
              child: const Icon(Icons.add, size: 30),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: _currentIndex < 2
            ? const CircularNotchedRectangle()
            : const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: _currentIndex < 2
              ? MainAxisAlignment.spaceAround
              : MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Beranda
            InkWell(
              onTap: () => _onTabTap(0),
              child: _Nav(Icons.home, 'Beranda', _currentIndex == 0),
            ),
            // Komunitas
            InkWell(
              onTap: () => _onTabTap(1),
              child:
                  _Nav(Icons.forum_outlined, 'Komunitas', _currentIndex == 1),
            ),
            // Ruang FAB — hanya ada saat tab Beranda / Komunitas
            if (_currentIndex < 2) const SizedBox(width: 48),
            // Notifikasi (dengan badge)
            Consumer<NotificationViewModel>(
              builder: (context, notifVm, _) => InkWell(
                onTap: () => _onTabTap(2),
                child: _NavBadge(
                  icon: Icons.notifications_none,
                  label: 'Notifikasi',
                  active: _currentIndex == 2,
                  badgeCount: notifVm.unreadCount,
                ),
              ),
            ),
            // Profil
            InkWell(
              onTap: () => _onTabTap(3),
              child: _Nav(
                  Icons.person_outline, 'Profil', _currentIndex == 3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Nav item biasa ──────────────────────────────────

class _Nav extends StatelessWidget {
  const _Nav(this.icon, this.label, this.active);

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color c = active ? AppColors.primary : AppColors.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: c),
        Text(label, style: TextStyle(fontSize: 11, color: c)),
      ],
    );
  }
}

// ─────────────────────────── Nav item dengan badge ───────────────────────────

class _NavBadge extends StatelessWidget {
  const _NavBadge({
    required this.icon,
    required this.label,
    required this.active,
    required this.badgeCount,
  });

  final IconData icon;
  final String label;
  final bool active;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final Color c = active ? AppColors.primary : AppColors.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: c),
            if (badgeCount > 0)
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 11, color: c)),
      ],
    );
  }
}
