import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared bottom navigation; the create action can be hidden on selected screens.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final int unreadCount;
  final bool showCreateButton;
  final Color selectedColor;
  final Color backgroundColor;
  final ValueChanged<int>
  onTap; // 0 Beranda, 1 Komunitas, 2 Notifikasi, 3 Profil
  final VoidCallback onCreate;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCreate,
    this.unreadCount = 0,
    this.showCreateButton = true,
    this.selectedColor = AppColors.primary,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: ColoredBox(
          color: backgroundColor,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _item(0, Icons.home_outlined, Icons.home, 'Beranda'),
                _item(1, Icons.forum_outlined, Icons.forum, 'Komunitas'),
                if (showCreateButton)
                  Expanded(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -10),
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          elevation: 4,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onCreate,
                            child: const Tooltip(
                              message: 'Buat Utas',
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                _item(
                  2,
                  Icons.notifications_outlined,
                  Icons.notifications,
                  'Notifikasi',
                  badge: unreadCount,
                ),
                _item(3, Icons.person_outline, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    int badge = 0,
  }) {
    final selected = currentIndex == index;
    final color = selected ? selectedColor : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: badge > 0,
              label: Text('$badge'),
              child: Icon(selected ? activeIcon : icon, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.caption,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
