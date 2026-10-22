import 'package:flutter/material.dart';
import 'package:unand_space/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const fieldLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const input = TextStyle(fontSize: 16, color: AppColors.textPrimary);
  static const hint = TextStyle(fontSize: 16, color: AppColors.textHint);
  static const helper = TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static const error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
  );
  static const sectionCaps = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );
  static const button = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
  static const dialogTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textSecondary,
  );
}
