import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Extra-accessible theme for screens the ELDER uses directly
/// (Home, Quiz). Caregiver-facing screens keep AppTheme.lightTheme as-is —
/// this is deliberately a bigger, plainer step up from that baseline, not
/// a replacement for it.
///
/// Design choices, and why:
/// - Body/button text is ~30-40% larger than the base theme's already-large
///   sizes, since elderly users doing a recall task benefit from a bigger
///   jump than general accessibility guidelines alone call for.
/// - Backgrounds are pure white (surfaceContainerLowest) rather than the
///   base theme's soft off-white, per the "mostly plain white" request —
///   less visual noise for the memory task itself to stand out against.
/// - Borders stay thick and black, same as the base theme, so it still
///   reads as the same app family.
class ElderTheme {
  ElderTheme._();

  static ThemeData get theme {
    final base = AppTheme.lightTheme;

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 40.0,
          fontWeight: FontWeight.w800,
          height: 1.2,
          color: AppColors.onSurface,
        ),
        headlineMedium: const TextStyle(
          fontSize: 34.0,
          fontWeight: FontWeight.w800,
          height: 1.25,
          color: AppColors.onSurface,
        ),
        titleLarge: const TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        bodyLarge: const TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.onSurface,
        ),
        bodyMedium: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.onSurface,
        ),
        labelLarge: const TextStyle(
          fontSize: 26.0,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          fontFamily: 'Atkinson Hyperlegible Next',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // Bigger than AppDimensions.touchTargetMin (64) — elder screens
          // get an even larger minimum tap target.
          minimumSize: const Size(double.infinity, 88.0),
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.roundedMedium,
            side: const BorderSide(color: AppColors.borderBlack, width: AppDimensions.thickBorderWidth),
          ),
          textStyle: const TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 88.0),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.borderBlack, width: AppDimensions.thickBorderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.roundedMedium,
          ),
          textStyle: const TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}