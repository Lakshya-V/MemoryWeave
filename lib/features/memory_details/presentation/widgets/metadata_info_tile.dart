import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class MetadataInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const MetadataInfoTile({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.roundedMedium,
        border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28.0, color: iconColor),
          const SizedBox(width: 14.0),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Atkinson Hyperlegible Next',
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
