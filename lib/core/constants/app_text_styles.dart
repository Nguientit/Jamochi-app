import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display — tên app, tiêu đề lớn
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
    fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.2,
  );

  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3,
  );

  // Heading — tiêu đề section
  static TextStyle get headingLarge => GoogleFonts.nunito(
    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark,
  );

  static TextStyle get headingMedium => GoogleFonts.nunito(
    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark,
  );

  static TextStyle get headingSmall => GoogleFonts.nunito(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark,
  );

  // Body — nội dung
  static TextStyle get bodyLarge => GoogleFonts.nunito(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textDark, height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMedium, height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.nunito(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textLight,
  );

  // Label — nút bấm, tag
  static TextStyle get labelLarge => GoogleFonts.nunito(
    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white, letterSpacing: 0.5,
  );

  static TextStyle get labelMedium => GoogleFonts.nunito(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark,
  );

  // Chat bubble
  static TextStyle get chatText => GoogleFonts.nunito(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textDark, height: 1.4,
  );

  static TextStyle get chatTime => GoogleFonts.nunito(
    fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textLight,
  );
}