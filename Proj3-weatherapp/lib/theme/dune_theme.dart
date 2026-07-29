import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dune_colors.dart';

class DuneTheme {
  static ThemeData get theme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: DuneColors.darkBackground,
      primaryColor: DuneColors.spiceOrange,
      colorScheme: const ColorScheme.dark(
        primary: DuneColors.spiceOrange,
        secondary: DuneColors.fremenBlue,
        surface: DuneColors.cardBackground,
        error: DuneColors.stormRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          color: DuneColors.duneGold,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
        displayMedium: GoogleFonts.cinzel(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          color: DuneColors.spiceOrange,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.montserrat(
          color: Colors.white70,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.montserrat(
          color: Colors.white60,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.rajdhani(
          color: DuneColors.fremenBlue,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: DuneColors.cardBackground.withOpacity(0.85),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: DuneColors.glassBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DuneColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: DuneColors.spiceOrange, width: 1.5),
        ),
      ),
    );
  }
}
