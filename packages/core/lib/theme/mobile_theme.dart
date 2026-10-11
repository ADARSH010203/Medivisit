import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class MediVisitMobileTheme extends ThemeExtension<MediVisitMobileTheme> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;

  const MediVisitMobileTheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.titleStyle,
    required this.bodyStyle,
  });

  @override
  ThemeExtension<MediVisitMobileTheme> copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    TextStyle? titleStyle,
    TextStyle? bodyStyle,
  }) {
    return MediVisitMobileTheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      titleStyle: titleStyle ?? this.titleStyle,
      bodyStyle: bodyStyle ?? this.bodyStyle,
    );
  }

  @override
  ThemeExtension<MediVisitMobileTheme> lerp(
      covariant ThemeExtension<MediVisitMobileTheme>? other, double t) {
    if (other is! MediVisitMobileTheme) return this;
    return MediVisitMobileTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      bodyStyle: TextStyle.lerp(bodyStyle, other.bodyStyle, t)!,
    );
  }

  static MediVisitMobileTheme get light => MediVisitMobileTheme(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.background,
    surface: AppColors.surface,
    titleStyle: AppTypography.titleMd,
    bodyStyle: AppTypography.bodyLg,
  );
  
  static MediVisitMobileTheme get dark => MediVisitMobileTheme(
    primary: AppColors.primaryLight,
    secondary: AppColors.tertiary,
    background: const Color(0xFF0F172A),
    surface: const Color(0xFF1E293B),
    titleStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFCBD5E1),
    ),
  );
}

ThemeData buildMobileTheme(bool isDark) {
  final ext = isDark ? MediVisitMobileTheme.dark : MediVisitMobileTheme.light;
  
  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: ext.primary,
      secondary: ext.secondary,
      surface: ext.surface, // Fixed: was ext.background
    ),
    scaffoldBackgroundColor: ext.background,
    fontFamily: AppTypography.fontFamily,
    extensions: [ext],
  );
}
