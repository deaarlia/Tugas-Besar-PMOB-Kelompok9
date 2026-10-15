import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF013220);
  static const Color background = Colors.white;
  static const Color chipBg = Color(0xFFE8F0FE);
  static const Color border = Color(0xFFD6E4F5);
  static const Color textDark = Color(0xFF0F1B2D);
  static const Color textMuted = Color(0xFF5B6470);
  static const Color avatarBg = Color(0xFFE2EFE9);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF013220);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      error: AppColors.error,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          height: 1.45,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
