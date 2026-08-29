import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class LoginTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePasswordVisibility;

  const LoginTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Atkinson Hyperlegible Next',
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: AppDimensions.touchTargetMin,
          decoration: BoxDecoration(
            color: isPassword ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
            borderRadius: AppDimensions.roundedSmall,
            border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              obscureText: isPassword && !isPasswordVisible,
              style: const TextStyle(
                fontFamily: 'Atkinson Hyperlegible Next',
                fontSize: 20.0,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Atkinson Hyperlegible Next',
                  fontSize: 18.0,
                  color: AppColors.outline,
                ),
                prefixIcon: Icon(
                  prefixIcon,
                  color: AppColors.onSurfaceVariant,
                  size: 28.0,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.onSurfaceVariant,
                          size: 28.0,
                        ),
                        onPressed: onTogglePasswordVisibility,
                        tooltip: 'Toggle password visibility',
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
