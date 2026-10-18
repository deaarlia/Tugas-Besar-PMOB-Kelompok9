import 'package:flutter/material.dart';

/// Warna diambil dari desain Figma (hijau Unand).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF026230);
  static const Color primaryLight = Color(0xFFD8F7E6);
  static const Color accent = Color(0xFF007C2F);
  static const Color chipBackground = Color(0xFFEAF1ED);
  static const Color surfaceAlt = Color(0xFFF4F6F5);
  static const Color divider = Color(0xFFE1E6E3);
  static const Color textSecondary = Color(0xFF5B6660);

  // Warna status laporan.
  static const Color statusWaitingBg = Color(0xFFFFF1CC);
  static const Color statusWaitingFg = Color(0xFF7A5700);
  static const Color statusProcessBg = Color(0xFFDCEBFF);
  static const Color statusProcessFg = Color(0xFF0B4A99);
  static const Color statusRejectedBg = Color(0xFFE8EAEC);
  static const Color statusRejectedFg = Color(0xFF4A5258);

  // Aksi berbahaya (Laporkan Postingan).
  static const Color dangerBg = Color(0xFFFDE8E8);
  static const Color dangerFg = Color(0xFFC62828);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1B1F1D),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B1F1D),
        ),
      ),
      dividerColor: AppColors.divider,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(64, 44),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
    );
  }
}