import 'package:flutter/material.dart';

/// Premium solid color theme for HackIFM
/// Carefully curated colors for a luxurious, professional feel
class AppTheme {
  // Primary Brand Colors - Deep Blue Palette
  static const Color primary = Color(0xFF1E3A8A); // Deep royal blue
  static const Color primaryLight = Color(0xFF3B82F6); // Bright blue
  static const Color primaryDark = Color(0xFF1E293B); // Very dark blue

  // Accent Colors - Premium Feel
  static const Color accent = Color(0xFF10B981); // Emerald green
  static const Color accentLight = Color(0xFF34D399); // Light emerald
  static const Color accentDark = Color(0xFF059669); // Deep emerald

  // Background Colors - Sophisticated Neutrals
  static const Color backgroundDark = Color(0xFF0F172A); // Deep navy background
  static const Color backgroundMedium = Color(0xFF1E293B); // Medium navy
  static const Color backgroundLight = Color(0xFFF8FAFC); // Light gray-blue

  // Surface Colors - Cards & Containers
  static const Color surface = Color(0xFF1E293B); // Dark surface
  static const Color surfaceLight = Color(0xFF334155); // Lighter surface
  static const Color surfaceElevated = Color(0xFF475569); // Elevated surface

  // Text Colors - Clear Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFFCBD5E1); // Light gray
  static const Color textTertiary = Color(0xFF94A3B8); // Medium gray
  static const Color textDisabled = Color(0xFF64748B); // Disabled gray

  // Semantic Colors - Status & Feedback
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Special UI Colors
  static const Color divider = Color(0xFF334155); // Divider line
  static const Color border = Color(0xFF475569); // Border color
  static const Color shadow = Color(0xFF000000); // Pure black for shadows

  // Glass/Overlay Effects
  static const Color overlay = Color(0x40000000); // Semi-transparent black
  static const Color glassLight = Color(0x1AFFFFFF); // Subtle white overlay
  static const Color glassDark = Color(0x1A000000); // Subtle black overlay

  /// Get shadow for premium elevation effect
  static List<BoxShadow> getElevationShadow({
    double elevation = 4,
    Color? color,
  }) {
    final shadowColor = color ?? shadow;
    return [
      BoxShadow(
        color: shadowColor.withOpacity(0.1 * elevation / 4),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
      BoxShadow(
        color: shadowColor.withOpacity(0.05 * elevation / 4),
        blurRadius: elevation * 4,
        offset: Offset(0, elevation),
      ),
    ];
  }

  /// Get glow effect for interactive elements
  static List<BoxShadow> getGlow({
    required Color color,
    double intensity = 1.0,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(0.4 * intensity),
        blurRadius: 20 * intensity,
        spreadRadius: 2 * intensity,
      ),
      BoxShadow(
        color: color.withOpacity(0.2 * intensity),
        blurRadius: 40 * intensity,
        spreadRadius: 4 * intensity,
      ),
    ];
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  /// Light theme configuration (for future use)
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: Colors.white,
        error: error,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: Color(0xFF1E293B),
        onError: textPrimary,
      ),
      // Similar configuration as dark theme...
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
