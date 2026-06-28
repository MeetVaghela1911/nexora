import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.background,
    primaryColor: AppColors.light.colorPrimary,
    dividerColor: AppColors.light.divider,
    textTheme: const TextTheme().apply(
      bodyColor: AppColors.light.textDark,
      displayColor: AppColors.light.textDark,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark.background,
    primaryColor: AppColors.dark.colorPrimary,
    dividerColor: AppColors.dark.divider,
    textTheme: const TextTheme().apply(
      bodyColor: AppColors.dark.textLight,
      displayColor: AppColors.dark.textLight,
    ),
  );
}
