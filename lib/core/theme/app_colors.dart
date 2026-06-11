import 'package:flutter/material.dart';

/// Premium dark color system for GUEZS FILMS.
class AppColors {
  AppColors._();

  // Brand tokens.
  static const Color brandBlue = Color(0xFF003366);
  static const Color brandBlueDark = Color(0xFF001C3D);
  static const Color brandGold = Color(0xFFD4AF37);
  static const Color brandGoldLight = Color(0xFFFFEFA6);
  static const Color spotlightBlue = Color(0xFF0099FF);

  // Cinema surfaces.
  static const Color bgCinema = Color(0xFF030914);
  static const Color bgCinemaDark = Color(0xFF00050D);
  static const Color surfaceObsidian = Color(0xFF101F33);
  static const Color cardObsidian = Color(0xFF12243A);

  // Dedicated contrast tokens.
  static const Color textOnGold = Color(0xFF030914);
  static const Color textOnBlue = Color(0xFFF9F9F9);

  // Compatibility aliases kept for existing screens.
  static const Color primary = brandBlue;
  static const Color primaryDark = brandBlueDark;
  static const Color accent = brandGold;
  static const Color accentSoft = brandGoldLight;
  static const Color background = bgCinema;
  static const Color surface = surfaceObsidian;
  static const Color surfaceVariant = Color(0xFF172C47);
  static const Color card = cardObsidian;
  static const Color bottomSheet = Color(0xFF081222);
  static const Color textOnPrimary = textOnBlue;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandBlue, brandBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bgCinema, bgCinemaDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [brandGold, Color(0xFFF2D172), brandGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text colors.
  static const Color textPrimary = Color(0xFFF9F9F9);
  static const Color textSecondary = Color(0xFFB8C5D6);
  static const Color textTertiary = Color(0xFF7E91A8);
  static const Color textDisabled = Color(0xFF4C5D72);

  // Semantic colors.
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFC400);
  static const Color error = Color(0xFFFF3366);
  static const Color info = spotlightBlue;

  // Lines and UI chrome.
  static const Color divider = Color(0xFF1B2C42);
  static const Color border = Color(0xFF243A54);
  static const Color shimmerBase = Color(0xFF102035);
  static const Color shimmerHighlight = Color(0xFF1D3554);
  static const Color overlay = Color(0x9900050D);
  static const Color overlayStrong = Color(0xDD00050D);

  // Genre/category colors.
  static const Color genreAction = Color(0xFFE53935);
  static const Color genreComedy = Color(0xFFFFB74D);
  static const Color genreDrama = Color(0xFF8E24AA);
  static const Color genreHorror = Color(0xFF101F33);
  static const Color genreRomance = Color(0xFFEC407A);
  static const Color genreSciFi = Color(0xFF00BCD4);
  static const Color genreThriller = Color(0xFF455A64);
  static const Color genreAnimation = Color(0xFF66BB6A);
  static const Color genreDocumentary = Color(0xFF5D4037);
  static const Color genreFantasy = Color(0xFF7C4DFF);

  // Rating colors.
  static const Color ratingHigh = success;
  static const Color ratingMedium = brandGold;
  static const Color ratingLow = error;

  static Color getRatingColor(double rating) {
    if (rating >= 8.0) return ratingHigh;
    if (rating >= 6.0) return ratingMedium;
    return ratingLow;
  }

  static Color glassBackground([double alpha = 0.58]) =>
      surfaceObsidian.withValues(alpha: alpha);

  static Color glassBorder([double alpha = 0.28]) =>
      brandGold.withValues(alpha: alpha);
}
