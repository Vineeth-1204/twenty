import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── COLOR TOKENS ──────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const navy      = Color(0xFF0D0D2B);
  static const navyMid   = Color(0xFF13133A);
  static const navyLight = Color(0xFF1B1B4B);
  static const pink      = Color(0xFFFF3EA5);
  static const pinkLight = Color(0xFFFF7FCF);
  static const cyan      = Color(0xFF00F5FF);
  static const cyanDark  = Color(0xFF00B8BF);
  static const yellow    = Color(0xFFFFE600);
  static const magenta   = Color(0xFFE0399F);
  static const purple    = Color(0xFF9B4DCA);
  static const cream     = Color(0xFFF0EEFF);
  static const error     = Color(0xFFFF2244);

  // Note card colors
  static const sakuraBg  = Color(0xFFFFD6E8);
  static const sakuraBdr = Color(0xFFFF3EA5);
  static const mintBg    = Color(0xFFC8FCE0);
  static const mintBdr   = Color(0xFF00C97A);
  static const lavBg     = Color(0xFFE4D4FF);
  static const lavBdr    = Color(0xFF9B4DCA);
  static const yolkBg    = Color(0xFFFFF6A0);
  static const yolkBdr   = Color(0xFFD4A000);
  static const neonBg    = Color(0xFFC0FAFF);
  static const neonBdr   = Color(0xFF00D4E8);
  static const paperBg   = Color(0xFFF8F0E3);
  static const paperBdr  = Color(0xFFC8B89A);
}

// ── NOTE COLOR ENUM ───────────────────────────────────────────────────────────
enum NoteColor { sakura, mint, lavender, yolk, neon, paper }

extension NoteColorExt on NoteColor {
  String get name {
    switch (this) {
      case NoteColor.sakura:   return 'sakura';
      case NoteColor.mint:     return 'mint';
      case NoteColor.lavender: return 'lavender';
      case NoteColor.yolk:     return 'yolk';
      case NoteColor.neon:     return 'neon';
      case NoteColor.paper:    return 'paper';
    }
  }

  Color get bg {
    switch (this) {
      case NoteColor.sakura:   return AppColors.sakuraBg;
      case NoteColor.mint:     return AppColors.mintBg;
      case NoteColor.lavender: return AppColors.lavBg;
      case NoteColor.yolk:     return AppColors.yolkBg;
      case NoteColor.neon:     return AppColors.neonBg;
      case NoteColor.paper:    return AppColors.paperBg;
    }
  }

  Color get border {
    switch (this) {
      case NoteColor.sakura:   return AppColors.sakuraBdr;
      case NoteColor.mint:     return AppColors.mintBdr;
      case NoteColor.lavender: return AppColors.lavBdr;
      case NoteColor.yolk:     return AppColors.yolkBdr;
      case NoteColor.neon:     return AppColors.neonBdr;
      case NoteColor.paper:    return AppColors.paperBdr;
    }
  }

  Color get textColor {
    switch (this) {
      case NoteColor.sakura:   return const Color(0xFF1A0010);
      case NoteColor.mint:     return const Color(0xFF001A0A);
      case NoteColor.lavender: return const Color(0xFF0E0025);
      case NoteColor.yolk:     return const Color(0xFF1A1000);
      case NoteColor.neon:     return const Color(0xFF001A1F);
      case NoteColor.paper:    return const Color(0xFF1A1000);
    }
  }

  String get emoji {
    switch (this) {
      case NoteColor.sakura:   return '🌸';
      case NoteColor.mint:     return '🍀';
      case NoteColor.lavender: return '💜';
      case NoteColor.yolk:     return '⭐';
      case NoteColor.neon:     return '💎';
      case NoteColor.paper:    return '📄';
    }
  }

  static NoteColor fromString(String s) {
    return NoteColor.values.firstWhere(
      (c) => c.name == s,
      orElse: () => NoteColor.sakura,
    );
  }
}

// ── THEME ─────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      surface:   AppColors.navyMid,
      primary:   AppColors.pink,
      secondary: AppColors.cyan,
      tertiary:  AppColors.yellow,
      error:     AppColors.error,
      onSurface: AppColors.cream,
      onPrimary: AppColors.navy,
    ),
    textTheme: GoogleFonts.notoSansJpTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: AppColors.cream, displayColor: AppColors.cream),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyMid,
      foregroundColor: AppColors.cream,
      elevation: 0,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.navyMid,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navy,
      hintStyle: TextStyle(color: Color(0x66F0EEFF)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.pink, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.cyan, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.pink, width: 2),
        borderRadius: BorderRadius.zero,
      ),
    ),
  );

  // Text styles
  static TextStyle pixelStyle({double size = 10, Color color = AppColors.cream}) =>
    GoogleFonts.pressStart2p(fontSize: size, color: color, height: 1.4);

  static TextStyle monoStyle({double size = 20, Color color = AppColors.cyan}) =>
    GoogleFonts.vt323(fontSize: size, color: color, height: 1);

  static TextStyle jpStyle({double size = 14, FontWeight weight = FontWeight.normal, Color color = AppColors.cream}) =>
    GoogleFonts.notoSansJp(fontSize: size, fontWeight: weight, color: color);
}
