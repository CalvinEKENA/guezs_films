import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Guezs Films Typography System
/// Using Poppins for display/headings and Montserrat for body text
class AppTextStyles {
  AppTextStyles._();

  // ─────────────────────────────────────────────────────────────────────────
  // Display Styles (Hero sections, large titles)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Headline Styles (Section headers, page titles)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.3,
  );

  static TextStyle headlineSmall = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Title Styles (Cards, list items, smaller headers)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle titleSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Body Styles (Paragraphs, descriptions)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Label Styles (Buttons, chips, badges)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle labelLarge = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.4,
  );

  static TextStyle labelMedium = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static TextStyle labelSmall = GoogleFonts.montserrat(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Caption Styles (Metadata, timestamps, helpers)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle caption = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.4,
    height: 1.4,
  );

  static TextStyle captionBold = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.4,
  );

  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Special Styles
  // ─────────────────────────────────────────────────────────────────────────

  /// Movie/Series title on cards
  static TextStyle movieTitle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.3,
  );

  /// Rating text style
  static TextStyle rating = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Year/Duration metadata
  static TextStyle metadata = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
  );

  /// Button text
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  /// Large button text
  static TextStyle buttonLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  /// Hero title for main banner
  static TextStyle heroTitle = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
    shadows: [
      Shadow(
        offset: const Offset(0, 2),
        blurRadius: 4,
        color: Colors.black.withValues(alpha: 0.5),
      ),
    ],
  );

  /// Top 10 ranking number
  static TextStyle rankingNumber = GoogleFonts.poppins(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    letterSpacing: -2,
    height: 1,
  );
}
