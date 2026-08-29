import 'package:flutter/material.dart';

/// Accent colors used across the dashboard menu cards.
/// Centralised here so every screen pulls from the same palette.
class AppColors {
  AppColors._();

  static const createNew = Color(0xFF0856E6);
  static const interior = Colors.pink;
  static const templates2D = Colors.red;
  static const templates3D = Colors.brown;
  static const makingCost =Colors.black38;
  static const myCreation = Color(0xFFFF26E2);

  static const bannerGradientStart = Color(0xFF7143E1);
  static const bannerGradientEnd = Color(0xFF5B3FE0);

  static const background = Color(0xFFF3EFFB);
  static const cardText = Color(0xFF1E1B33);
}

/// Material 3 theme for the whole app. Kept in one place so tweaking
/// brand colors later doesn't mean hunting through every screen.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.bannerGradientEnd,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue.shade100),
        ),
      ),
    );
  }
}
