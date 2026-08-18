import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color palette and theme definitions for Sudoku Master.
/// Uses a deep navy + electric blue palette for dark mode,
/// and a warm cream + midnight blue for light mode.
class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const primary = Color(0xFF6C63FF);      // Electric violet
  static const primaryLight = Color(0xFF9C95FF);
  static const accent = Color(0xFF00D9C5);        // Teal accent
  static const error = Color(0xFFFF5252);
  static const warning = Color(0xFFFFB74D);
  static const success = Color(0xFF69F0AE);

  // ── Dark Palette ─────────────────────────────────────────────────────────
  static const darkBg = Color(0xFF0F1117);
  static const darkSurface = Color(0xFF1A1D2E);
  static const darkCard = Color(0xFF22263A);
  static const darkBorder = Color(0xFF2E3250);
  static const darkText = Color(0xFFE8EAFF);
  static const darkSubtext = Color(0xFF8890B5);

  // ── Light Palette ────────────────────────────────────────────────────────
  static const lightBg = Color(0xFFF5F5F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFF0F0F8);
  static const lightBorder = Color(0xFFDDDDF0);
  static const lightText = Color(0xFF1A1D2E);
  static const lightSubtext = Color(0xFF6B7280);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: darkSurface,
        background: darkBg,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: darkText,
        onBackground: darkText,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
          .apply(bodyColor: darkText, displayColor: darkText),
      cardColor: darkCard,
      dividerColor: darkBorder,
      iconTheme: const IconThemeData(color: darkText),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: lightSurface,
        background: lightBg,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: lightText,
        onBackground: lightText,
      ),
      scaffoldBackgroundColor: lightBg,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme)
          .apply(bodyColor: lightText, displayColor: lightText),
      cardColor: lightSurface,
      dividerColor: lightBorder,
      iconTheme: const IconThemeData(color: lightText),
    );
  }
}

/// Extension for quick access to semantic colors
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bgColor =>
      isDark ? AppTheme.darkBg : AppTheme.lightBg;
  Color get surfaceColor =>
      isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
  Color get cardColor =>
      isDark ? AppTheme.darkCard : AppTheme.lightCard;
  Color get borderColor =>
      isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
  Color get textColor =>
      isDark ? AppTheme.darkText : AppTheme.lightText;
  Color get subtextColor =>
      isDark ? AppTheme.darkSubtext : AppTheme.lightSubtext;
}
