import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // Build ThemeData từ MoodPalette
  static ThemeData fromPalette(MoodPalette palette) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.primary,

      colorScheme: ColorScheme.light(
        primary:   palette.accent,
        secondary: palette.secondary,
        surface:   palette.primary,
        onPrimary: Colors.white,
        onSurface: AppColors.textDark,
      ),

      textTheme: GoogleFonts.nunitoTextTheme(),

      // AppBar trong suốt, không có shadow
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),

      // Bottom Nav Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.9),
        selectedItemColor: palette.accent,
        unselectedItemColor: AppColors.textLight,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.nunito(fontSize: 11),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.secondary.withAlpha((0.3 * 255).round())),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.nunito(color: AppColors.textLight, fontSize: 15),
        labelStyle: GoogleFonts.nunito(color: AppColors.textMedium, fontSize: 15),
      ),

      // Card
      cardTheme: CardThemeData(
        color: const Color.fromRGBO(255, 255, 255, 0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.accent,
          textStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Theme mặc định (normal/cream) khi chưa load mood
  static ThemeData get defaultTheme =>
      fromPalette(AppColors.getPalette('normal'));
}