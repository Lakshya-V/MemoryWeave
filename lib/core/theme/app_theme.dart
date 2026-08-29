import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Central theme configuration with high contrast, clear borders, and accessible typography
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Atkinson Hyperlegible Next',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.01,
          height: 1.25,
          color: AppColors.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
          height: 1.28,
          color: AppColors.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
          height: 1.55,
          color: AppColors.onSurface,
        ),
        labelLarge: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.onSurface,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          fontFamily: 'Atkinson Hyperlegible Next',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppDimensions.touchTargetMin),
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.roundedMedium,
            side: const BorderSide(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
          ),
          textStyle: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppDimensions.touchTargetMin),
          backgroundColor: AppColors.surfaceContainerLowest,
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.roundedMedium,
          ),
          textStyle: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.roundedSmall,
          borderSide: const BorderSide(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.roundedSmall,
          borderSide: const BorderSide(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.roundedSmall,
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 3.0),
        ),
        hintStyle: const TextStyle(
          fontSize: 18.0,
          color: AppColors.outline,
        ),
      ),
    );
  }
}
