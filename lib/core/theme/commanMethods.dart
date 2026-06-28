import 'package:flutter/material.dart';
import 'package:nexora/core/theme/app_colors.dart';

AppColorScheme getThemeBaseColors(BuildContext context){
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors = isDark ? AppColors.dark : AppColors.light;
  return colors;
}