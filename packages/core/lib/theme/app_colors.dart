import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF008080); // Teal
  static const Color primaryDark = Color(0xFF006666);
  static const Color primaryLight = Color(0xFF339999);
  
  static const Color secondary = Color(0xFF4F378A); // Deep Purple
  static const Color tertiary = Color(0xFF7C5CFF); // AI Accent

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color background = Color(0xFFF8FAFC);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Admin Specific
  static const Color adminBackground = Color(0xFF0F172A);
  static const Color adminSurface = Color(0xFF1E293B);
  static const Color adminSurfaceHighlight = Color(0xFF334155);

  // Gradients
  // Admin Specific Gradients
  static const Color adminAccentStart = Color(0xFF38BDF8); // Sky
  static const Color adminAccentEnd = Color(0xFF818CF8); // Indigo

  static const LinearGradient brandGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient adminBrandGradient = LinearGradient(
    colors: [adminAccentStart, adminAccentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
