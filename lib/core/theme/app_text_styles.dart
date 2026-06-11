import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Guezs Films typography system.
/// Cinzel carries prestige titles, Outfit handles UI, Montserrat handles body.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayPrestige = GoogleFonts.cinzel(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.1,
  );

  static TextStyle displayLarge = GoogleFonts.cinzel(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.cinzel(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.cinzel(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle heroTitle = GoogleFonts.cinzel(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.1,
    shadows: [
      Shadow(
        offset: const Offset(0, 2),
        blurRadius: 8,
        color: Colors.black.withValues(alpha: 0.55),
      ),
    ],
  );

  static TextStyle headlineLarge = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.3,
  );

  static TextStyle headlineSmall = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle sectionTitle = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle titleLarge = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.3,
  );

  static TextStyle titleMedium = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle titleSmall = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
    height: 1.45,
  );

  static TextStyle bodySmall = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle labelLarge = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle labelMedium = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle labelSmall = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle caption = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle captionBold = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle overline = GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.brandGoldLight,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle badge = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.brandGoldLight,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle movieTitle = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.3,
  );

  static TextStyle rating = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.brandGold,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle metadata = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle buttonLabel = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnGold,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle button = buttonLabel.copyWith(fontSize: 14);

  static TextStyle buttonLarge = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnGold,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle rankingNumber = GoogleFonts.outfit(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1,
  );
}
