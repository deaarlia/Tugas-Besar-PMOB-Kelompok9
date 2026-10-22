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

class AppTypography {
  AppTypography._();

  static const double pageTitle = 18;
  static const double sectionTitle = 14.5;
  static const double body = 13;
  static const double label = 12;
  static const double caption = 11;
  static const double micro = 10;
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
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: AppTypography.pageTitle,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleMedium: TextStyle(
          fontSize: AppTypography.sectionTitle,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTypography.body,
          color: AppColors.textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTypography.label,
          color: AppColors.textDark,
        ),
        bodySmall: TextStyle(
          fontSize: AppTypography.caption,
          color: AppColors.textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: AppTypography.label,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontSize: AppTypography.caption,
          fontWeight: FontWeight.w600,
        ),
      ),
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
          fontSize: AppTypography.pageTitle,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: AppTypography.body,
          height: 1.45,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: AppTypography.pageTitle,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
