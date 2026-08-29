import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Primary/Secondary Accessible Button with 64px minimum touch target
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? suffixIcon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final bool isFullWidth;
  final List<BoxShadow>? boxShadow;

  const AccessibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.suffixIcon,
    this.backgroundColor = AppColors.primaryContainer,
    this.foregroundColor = AppColors.onPrimary,
    this.height = AppDimensions.touchTargetMin,
    this.isFullWidth = true,
    this.boxShadow,
  });

  factory AccessibleButton.primary({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? suffixIcon,
    double height = AppDimensions.touchTargetMin,
    bool isFullWidth = true,
    List<BoxShadow>? boxShadow,
  }) {
    return AccessibleButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      suffixIcon: suffixIcon,
      backgroundColor: AppColors.primaryContainer,
      foregroundColor: AppColors.onPrimary,
      height: height,
      isFullWidth: isFullWidth,
      boxShadow: boxShadow,
    );
  }

  factory AccessibleButton.success({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? suffixIcon,
    double height = AppDimensions.touchTargetMin,
    bool isFullWidth = true,
    List<BoxShadow>? boxShadow,
  }) {
    return AccessibleButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      suffixIcon: suffixIcon,
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.onSecondary,
      height: height,
      isFullWidth: isFullWidth,
      boxShadow: boxShadow,
    );
  }

  factory AccessibleButton.outlined({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? suffixIcon,
    double height = AppDimensions.touchTargetMin,
    bool isFullWidth = true,
    List<BoxShadow>? boxShadow,
  }) {
    return AccessibleButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      suffixIcon: suffixIcon,
      backgroundColor: AppColors.surfaceContainerLowest,
      foregroundColor: AppColors.onSurface,
      height: height,
      isFullWidth: isFullWidth,
      boxShadow: boxShadow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 28.0, color: foregroundColor),
          const SizedBox(width: 10.0),
        ],
        Text(
          text,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'Atkinson Hyperlegible Next',
          ),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: 10.0),
          Icon(suffixIcon, size: 28.0, color: foregroundColor),
        ],
      ],
    );

    return Container(
      height: height,
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDimensions.roundedMedium,
        border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppDimensions.roundedMedium,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
