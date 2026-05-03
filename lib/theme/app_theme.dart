import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFFF6F2);
  static const card = Colors.white;
  static const accentPink = Color(0xFFFF6B9A);
  static const accentYellow = Color(0xFFFFE066);
  static const textPrimary = Color(0xFF1B1B1F);
  static const textMuted = Color(0xFF7A7A82);
  static const chipBg = Color(0xFFFDF1E7);
  static const chipActive = Color(0xFFCFF2D6);
  static const navBg = Color(0xFF1B1B1F);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentPink,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
  );
}
