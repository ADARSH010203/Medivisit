import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class MediVisitAdminTheme extends ThemeExtension<MediVisitAdminTheme> {
  final Color primary;
  final Color background;
  final Color surface;
  final Color border;
  final TextStyle headlineStyle;
  final TextStyle bodyStyle;

  const MediVisitAdminTheme({
    required this.primary,
    required this.background,
    required this.surface,
    required this.border,
    required this.headlineStyle,
    required this.bodyStyle,
  });

  @override
  ThemeExtension<MediVisitAdminTheme> copyWith({
    Color? primary,
    Color? background,
    Color? surface,
    Color? border,
    TextStyle? headlineStyle,
    TextStyle? bodyStyle,
  }) {
    return MediVisitAdminTheme(
      primary: primary ?? this.primary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      headlineStyle: headlineStyle ?? this.headlineStyle,
      bodyStyle: bodyStyle ?? this.bodyStyle,
    );
  }

  @override
  ThemeExtension<MediVisitAdminTheme> lerp(
      covariant ThemeExtension<MediVisitAdminTheme>? other, double t) {
    if (other is! MediVisitAdminTheme) return this;
    return MediVisitAdminTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      headlineStyle: TextStyle.lerp(headlineStyle, other.headlineStyle, t)!,
      bodyStyle: TextStyle.lerp(bodyStyle, other.bodyStyle, t)!,
    );
  }

  static MediVisitAdminTheme get dark => MediVisitAdminTheme(
    primary: const Color(0xFF38BDF8), // Cyan
    background: AppColors.adminBackground,
    surface: AppColors.adminSurface,
    border: AppColors.adminSurfaceHighlight,
    headlineStyle: AppTypography.adminHeadline,
    bodyStyle: AppTypography.adminBody,
  );
}

ThemeData buildAdminTheme() {
  final ext = MediVisitAdminTheme.dark;
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: ext.primary,
      surface: ext.surface,
    ),
    scaffoldBackgroundColor: ext.background,
    fontFamily: AppTypography.adminFontFamily,
    extensions: [ext],
  );
}
