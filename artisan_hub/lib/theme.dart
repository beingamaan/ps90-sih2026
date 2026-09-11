import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CraftTheme {
  // ─── CRAFTBRIDGE COLOUR SYSTEM (PHASE 3.5) ────────────────
  static const Color creamBase = Color(0xFFF7F3ED);       // Primary background: Warm Parchment
  static const Color cardSurface = Color(0xFFFFFDFC);     // Primary surface: Soft Ivory
  static const Color darkText = Color(0xFF292522);        // Primary text: Charcoal Brown
  static const Color mutedText = Color(0xFF6F6963);       // Secondary text: Warm Grey
  static const Color captionText = Color(0xFF8D8680);     // Caption / Helper text
  static const Color borderLight = Color(0xFFDED6CC);     // Borders/dividers: Sandstone

  // Primary Brand — Terracotta
  static const Color terracottaPrimary = Color(0xFFD94A2B); // Primary brand / CTAs
  static const Color terracottaDark = Color(0xFFB83B22);    // Primary hover/pressed: Deep Terracotta
  static const Color terracottaLight = Color(0xFFF6E4DC);   // Light brand surface: Clay Tint

  // Trust / Seller Control — Muted Teal
  static const Color tealTint = Color(0xFF16877C);         // Trust / seller-confirmed
  static const Color tealLight = Color(0xFFE5F2EF);        // Trust background: Pale Sage

  // Voice Interaction — Dusty Plum
  static const Color violetTint = Color(0xFF7656B8);       // Voice interaction / mic
  static const Color violetLight = Color(0xFFEEE9FA);      // Voice background: Soft Lavender

  // Review / Attention — Ochre
  static const Color amberTint = Color(0xFFA87528);        // Review / attention / warning
  static const Color amberLight = Color(0xFFF7EEDB);       // Review background: Warm Sand

  // ─── LEGACY COLOR ALIASES (Mapped to Phase 3.5 Palette) ────
  static const Color blueLight = tealLight;
  static const Color blueTint = tealTint;
  static const Color coralLight = terracottaLight;
  static const Color coralTint = terracottaPrimary;
  static const Color greenLight = tealLight;
  static const Color greenTint = tealTint;

  // Maximum content width for Desktop Web Responsiveness
  static const double maxDesktopContentWidth = 1140.0;

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
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
          height: 1.25,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkText,
          height: 1.3,
        ),
        titleMedium: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
          height: 1.35,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 15,
          color: darkText,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          color: mutedText,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          color: captionText,
          height: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
    );
  }

  // ─── REUSABLE WIDGET HELPERS ───────────────────────────

  /// Icon Badge Container Helper
  static Widget iconBadge({
    required IconData icon,
    required Color color,
    required Color lightColor,
    double outerSize = 48,
    double innerSize = 32,
    double iconSize = 20,
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

  /// Contextual Tag Chip Helper
  static Widget tagChip(String label, {Color? bg, Color? text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg ?? terracottaLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderLight, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: text ?? darkText,
        ),
      ),
    );
  }
}

