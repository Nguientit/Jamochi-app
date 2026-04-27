import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // không cho khởi tạo

  // ── 7 Mood Palettes ──────────────────────────────────────────────────────────
  // 😐 Normal (Cream)
  static const Color normalPrimary   = Color(0xFFFFF5E4);
  static const Color normalSecondary = Color(0xFFE8D5C4);
  static const Color normalAccent    = Color(0xFFD4A96A);

  // 😊 Happy (Peach)
  static const Color happyPrimary    = Color(0xFFFFDAC1);
  static const Color happySecondary  = Color(0xFFFFB347);
  static const Color happyAccent     = Color(0xFFFF8C42);

  // 😢 Sad (Lavender)
  static const Color sadPrimary      = Color(0xFFC8B6E2);
  static const Color sadSecondary    = Color(0xFF9B8EC4);
  static const Color sadAccent       = Color(0xFF7B6FA0);

  // 😠 Angry (Coral)
  static const Color angryPrimary    = Color(0xFFFF9AA2);
  static const Color angrySecondary  = Color(0xFFFF6B6B);
  static const Color angryAccent     = Color(0xFFE84545);

  // 😴 Tired (Mint)
  static const Color tiredPrimary    = Color(0xFFB5EAD7);
  static const Color tiredSecondary  = Color(0xFF78C2A4);
  static const Color tiredAccent     = Color(0xFF4AA688);

  // 😰 Anxious (Sky)
  static const Color anxiousPrimary   = Color(0xFFAED9E0);
  static const Color anxiousSecondary = Color(0xFF5BC8D6);
  static const Color anxiousAccent    = Color(0xFF2BAEBF);

  // 🥰 Romantic (Rose)
  static const Color romanticPrimary   = Color(0xFFFFD6E0);
  static const Color romanticSecondary = Color(0xFFFF85A2);
  static const Color romanticAccent    = Color(0xFFE8547A);

  // ── Semantic / UI Colors ────────────────────────────────────────────────────
  static const Color white       = Color(0xFFFFFFFF);
  static const Color black       = Color(0xFF1A1A1A);
  static const Color textDark    = Color(0xFF2D2D2D);
  static const Color textMedium  = Color(0xFF6B6B6B);
  static const Color textLight   = Color(0xFFAAAAAA);
  static const Color divider     = Color(0xFFEEEEEE);
  static const Color error       = Color(0xFFE84545);
  static const Color success     = Color(0xFF4CAF50);

  // ── Helper: lấy palette theo mood string ────────────────────────────────────
  static MoodPalette getPalette(String mood) {
    switch (mood) {
      case 'happy':    return MoodPalette(happyPrimary,    happySecondary,    happyAccent,    '😊');
      case 'sad':      return MoodPalette(sadPrimary,      sadSecondary,      sadAccent,      '😢');
      case 'angry':    return MoodPalette(angryPrimary,    angrySecondary,    angryAccent,    '😠');
      case 'tired':    return MoodPalette(tiredPrimary,    tiredSecondary,    tiredAccent,    '😴');
      case 'anxious':  return MoodPalette(anxiousPrimary,  anxiousSecondary,  anxiousAccent,  '😰');
      case 'romantic': return MoodPalette(romanticPrimary, romanticSecondary, romanticAccent, '🥰');
      default:         return MoodPalette(normalPrimary,   normalSecondary,   normalAccent,   '😐');
    }
  }
}

class MoodPalette {
  final Color primary;
  final Color secondary;
  final Color accent;
  final String emoji;
  const MoodPalette(this.primary, this.secondary, this.accent, this.emoji);
}