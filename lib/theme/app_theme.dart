import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Geist',
      scaffoldBackgroundColor: AppColors.white,
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.white,
      ),
      // Make colors accessible via theme extensions
      extensions: <ThemeExtension<dynamic>>[
        AppColorScheme(
          border: AppColors.border,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          lightGray: AppColors.lightGray,
        ),
      ],
    );
  }
}

/// Theme extension to access custom colors throughout the app
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color border;
  final Color primary;
  final Color secondary;
  final Color lightGray;

  AppColorScheme({
    required this.border,
    required this.primary,
    required this.secondary,
    required this.lightGray,
  });

  @override
  AppColorScheme copyWith({
    Color? border,
    Color? primary,
    Color? secondary,
    Color? lightGray,
  }) {
    return AppColorScheme(
      border: border ?? this.border,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      lightGray: lightGray ?? this.lightGray,
    );
  }

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) {
      return this;
    }
    return AppColorScheme(
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      lightGray: Color.lerp(lightGray, other.lightGray, t)!,
    );
  }
}

/// Extension to easily access custom colors from BuildContext
extension AppColorsExtension on BuildContext {
  AppColorScheme get appColors =>
      Theme.of(this).extension<AppColorScheme>() ??
      AppColorScheme(
        border: AppColors.border,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        lightGray: AppColors.lightGray,
      );
}

