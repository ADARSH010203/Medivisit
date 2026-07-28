import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Using Inter as the default font family for mobile
  static String? get fontFamily => GoogleFonts.inter().fontFamily;
  
  // Using Inter as the default font family for admin
  static String? get adminFontFamily => GoogleFonts.inter().fontFamily;

  // Mobile TextStyles
  static TextStyle get displayHero => GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineLg => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMd => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelCaps => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  // Admin TextStyles
  static TextStyle get adminHeadline => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get adminBody => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFCBD5E1),
  );
}
