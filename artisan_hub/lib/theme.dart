import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CraftTheme {
  // ─── COLOR PALETTE ─────────────────────────────────────
  static const Color creamBase = Color(0xFFFAF8F5);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF212121);
  static const Color mutedText = Color(0xFF666666);
  static const Color borderLight = Color(0xFFEAE5DF);

  // Primary Terracotta/Coral Brand Accent
  static const Color terracottaPrimary = Color(0xFFE05638);
  static const Color terracottaLight = Color(0xFFFBEBE8);

  // Functional Tints
  static const Color violetTint = Color(0xFF7C4DFF);
  static const Color violetLight = Color(0xFFF0EBFF);

  static const Color tealTint = Color(0xFF00BFA5);
  static const Color tealLight = Color(0xFFE0F7F4);

  static const Color coralTint = Color(0xFFE05638);
  static const Color coralLight = Color(0xFFFBEBE8);

  static const Color blueTint = Color(0xFF2979FF);
  static const Color blueLight = Color(0xFFE8F1FF);

  static const Color greenTint = Color(0xFF00C853);
  static const Color greenLight = Color(0xFFE6F9ED);

  // Tag Pill Tint Colors Cycle
  static const List<Color> tagBgColors = [
    Color(0xFFF0EBFF),
    Color(0xFFFBEBE8),
    Color(0xFFE0F7F4),
    Color(0xFFE8F1FF),
  ];
  
  static const List<Color> tagTextColors = [
    Color(0xFF7C4DFF),
    Color(0xFFE05638),
    Color(0xFF00BFA5),
    Color(0xFF2979FF),
  ];

  // ─── THEME DATA ────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamBase,
      colorScheme: ColorScheme.fromSeed(
        seedColor: terracottaPrimary,
        primary: terracottaPrimary,
        surface: cardSurface,
      ),
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        titleMedium: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 15,
          color: darkText,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          color: mutedText,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
    );
  }

  // ─── REUSABLE WIDGET HELPERS ───────────────────────────

  /// Icon-in-Icon Badge Button
  static Widget iconBadge({
    required IconData icon,
    required Color color,
    required Color lightColor,
    double outerSize = 44,
    double innerSize = 28,
    double iconSize = 18,
  }) {
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        color: lightColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }

  /// Pill Tag Chip
  static Widget tagChip(String label, int index) {
    final bg = tagBgColors[index % tagBgColors.length];
    final text = tagTextColors[index % tagTextColors.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
