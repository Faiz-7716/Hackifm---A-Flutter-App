import 'package:flutter/material.dart';

/// Modern Blue Authentication Theme Colors
/// Following Material 3 design principles with vibrant blue brand identity
class AuthColors {
  // ==================== PRIMARY BRAND COLORS ====================

  /// Primary Brand Color - Vibrant Blue
  /// Used in: Buttons, Wave decorations, Active states
  static const Color primary = Color(0xFF3B82F6);

  /// Secondary/Gradient Color - Lighter Blue
  /// Used in: Gradient backgrounds for waves and buttons to add depth
  static const Color secondary = Color(0xFF60A5FA);

  /// Primary Dark Variant - Deeper Blue
  static const Color primaryDark = Color(0xFF2563EB);

  /// Primary Light Variant - Sky Blue
  static const Color primaryLight = Color(0xFF93C5FD);

  // ==================== BACKGROUND COLORS ====================

  /// Background Color (Dark Mode) - Slate 900
  /// Used in: Scaffold background for a deep, modern dark mode look
  static const Color backgroundDark = Color(0xFF0F172A);

  /// Background Color (Light Mode) - Pure White
  static const Color backgroundLight = Color(0xFFFFFFFF);

  /// Surface Color (Dark Mode) - Slate 800
  /// Used in: Cards and input fields
  static const Color surfaceDark = Color(0xFF1E293B);

  /// Surface Color (Light Mode) - Slate 50
  static const Color surfaceLight = Color(0xFFF8FAFC);

  /// Surface Elevated (Dark Mode) - Slate 700
  static const Color surfaceElevatedDark = Color(0xFF334155);

  /// Surface Elevated (Light Mode) - White
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);

  // ==================== TEXT COLORS ====================

  /// Text Primary (Dark Mode) - Pure White
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  /// Text Primary (Light Mode) - Slate 900
  static const Color textPrimaryLight = Color(0xFF0F172A);

  /// Text Secondary (Dark Mode) - Slate 400
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  /// Text Secondary (Light Mode) - Slate 600
  static const Color textSecondaryLight = Color(0xFF475569);

  /// Text Tertiary (Dark Mode) - Slate 500
  static const Color textTertiaryDark = Color(0xFF64748B);

  /// Text Tertiary (Light Mode) - Slate 500
  static const Color textTertiaryLight = Color(0xFF64748B);

  // ==================== SEMANTIC COLORS ====================

  /// Success Color - Emerald Green
  static const Color success = Color(0xFF10B981);

  /// Warning Color - Amber
  static const Color warning = Color(0xFFF59E0B);

  /// Error/Danger Color - Red
  static const Color error = Color(0xEF4444);

  /// Info Color - Sky Blue
  static const Color info = Color(0xFF0EA5E9);

  // ==================== UI ELEMENT COLORS ====================

  /// Divider Color (Dark Mode)
  static const Color dividerDark = Color(0xFF334155);

  /// Divider Color (Light Mode)
  static const Color dividerLight = Color(0xFFE2E8F0);

  /// Border Color (Dark Mode)
  static const Color borderDark = Color(0xFF475569);

  /// Border Color (Light Mode)
  static const Color borderLight = Color(0xFFCBD5E1);

  /// Shadow Color
  static const Color shadow = Color(0xFF000000);

  // ==================== GRADIENT DEFINITIONS ====================

  /// Primary Gradient - Blue to Lighter Blue
  /// Used in: Buttons, Wave animations, CTAs
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Reverse Primary Gradient
  static const LinearGradient primaryGradientReverse = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Wave Gradient - For decorative wave elements
  static const LinearGradient waveGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA), Color(0xFF93C5FD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ==================== HELPER METHODS ====================

  /// Get appropriate text color based on theme brightness
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimaryLight;
  }

  /// Get appropriate text secondary color based on theme brightness
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondaryLight;
  }

  /// Get appropriate surface color based on theme brightness
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }

  /// Get appropriate background color based on theme brightness
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  /// Get box shadow for elevation effect
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
  static List<BoxShadow> getGlow({Color? color, double intensity = 1.0}) {
    final glowColor = color ?? primary;
    return [
      BoxShadow(
        color: glowColor.withOpacity(0.4 * intensity),
        blurRadius: 20 * intensity,
        spreadRadius: 2 * intensity,
      ),
      BoxShadow(
        color: glowColor.withOpacity(0.2 * intensity),
        blurRadius: 40 * intensity,
        spreadRadius: 4 * intensity,
      ),
    ];
  }
}
