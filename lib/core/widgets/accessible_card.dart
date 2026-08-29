import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Reusable Card component with crisp 2px solid black border and custom background
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double borderWidth;
  final Color borderColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const AccessibleCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.surfaceContainerLowest,
    this.padding = const EdgeInsets.all(AppDimensions.gutter),
    this.borderWidth = AppDimensions.borderWidth,
    this.borderColor = AppColors.borderBlack,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius ?? AppDimensions.roundedLarge,
      side: BorderSide(color: borderColor, width: borderWidth),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius ?? AppDimensions.roundedLarge,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: boxShadow,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
