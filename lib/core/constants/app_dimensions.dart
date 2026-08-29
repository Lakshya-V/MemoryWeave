import 'package:flutter/material.dart';

/// Spacing and sizing tokens prioritizing accessibility and large touch targets
class AppDimensions {
  AppDimensions._();

  static const double containerMargin = 24.0;
  static const double stackGap = 20.0;
  static const double gutter = 16.0;
  static const double touchTargetMin = 64.0;
  static const double borderWidth = 2.0;
  static const double thickBorderWidth = 4.0;

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusExtraLarge = 16.0;
  static const double radiusFull = 999.0;

  static const BorderRadius roundedSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius roundedMedium = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius roundedLarge = BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius roundedExtraLarge = BorderRadius.all(Radius.circular(radiusExtraLarge));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(radiusFull));
}
