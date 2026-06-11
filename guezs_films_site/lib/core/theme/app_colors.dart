import 'package:flutter/material.dart';

/// Guezs Films Color System
/// A premium dark-first color palette optimized for OLED displays
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────────────────────────────
  // Primary Brand Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Guezs signature red - primary brand color
  static const Color primary = Color(0xFFE50914);

  /// Darker red for gradients and pressed states
  static const Color primaryDark = Color(0xFFB20710);

  /// Primary gradient (signature Guezs gradient)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Background & Surface Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Deep black background - optimized for OLED
  static const Color background = Color(0xFF0A0A0A);

  /// Slightly elevated surface
  static const Color surface = Color(0xFF1A1A1A);

  /// Higher elevation surface
  static const Color surfaceVariant = Color(0xFF2A2A2A);

  /// Card background with subtle transparency
  static const Color card = Color(0xFF1E1E1E);

  /// Bottom sheet / dialog background
  static const Color bottomSheet = Color(0xFF141414);

  // ─────────────────────────────────────────────────────────────────────────
  // Accent Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Gold accent for premium elements
  static const Color accent = Color(0xFFFFD700);

  /// Secondary accent (softer gold)
  static const Color accentSoft = Color(0xFFD4AF37);

  /// Success green
  static const Color success = Color(0xFF46D369);

  /// Warning orange
  static const Color warning = Color(0xFFFF9800);

  /// Error red (softer than primary)
  static const Color error = Color(0xFFCF6679);

  /// Info blue
  static const Color info = Color(0xFF2196F3);

  // ─────────────────────────────────────────────────────────────────────────
  // Text Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary text - pure white
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text - light grey
  static const Color textSecondary = Color(0xFFE5E5E5);

  /// Tertiary text - grey
  static const Color textTertiary = Color(0xFFB3B3B3);

  /// Disabled text
  static const Color textDisabled = Color(0xFF757575);

  /// Text on primary color
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────────────────────────────
  // UI Element Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Divider color
  static const Color divider = Color(0xFF333333);

  /// Border color
  static const Color border = Color(0xFF3D3D3D);

  /// Shimmer base color
  static const Color shimmerBase = Color(0xFF2A2A2A);

  /// Shimmer highlight color
  static const Color shimmerHighlight = Color(0xFF3D3D3D);

  /// Overlay color for gradients on images
  static const Color overlay = Color(0x80000000);

  /// Strong overlay
  static const Color overlayStrong = Color(0xCC000000);

  // ─────────────────────────────────────────────────────────────────────────
  // Genre/Category Colors
  // ─────────────────────────────────────────────────────────────────────────

  static const Color genreAction = Color(0xFFE53935);
  static const Color genreComedy = Color(0xFFFFB74D);
  static const Color genreDrama = Color(0xFF8E24AA);
  static const Color genreHorror = Color(0xFF1E1E1E);
  static const Color genreRomance = Color(0xFFEC407A);
  static const Color genreSciFi = Color(0xFF00BCD4);
  static const Color genreThriller = Color(0xFF455A64);
  static const Color genreAnimation = Color(0xFF66BB6A);
  static const Color genreDocumentary = Color(0xFF5D4037);
  static const Color genreFantasy = Color(0xFF7C4DFF);

  // ─────────────────────────────────────────────────────────────────────────
  // Rating Colors
  // ─────────────────────────────────────────────────────────────────────────

  static const Color ratingHigh = Color(0xFF46D369); // 8.0+
  static const Color ratingMedium = Color(0xFFFFD700); // 6.0-7.9
  static const Color ratingLow = Color(0xFFE50914); // Below 6.0

  /// Get color based on rating value
  static Color getRatingColor(double rating) {
    if (rating >= 8.0) return ratingHigh;
    if (rating >= 6.0) return ratingMedium;
    return ratingLow;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Glassmorphism
  // ─────────────────────────────────────────────────────────────────────────

  /// Glass card background
  static Color glassBackground = Colors.white.withValues(alpha: 0.1);

  /// Glass border color
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
}
