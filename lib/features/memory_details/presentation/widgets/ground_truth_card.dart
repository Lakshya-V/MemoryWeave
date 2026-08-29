import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/accessible_card.dart';

class GroundTruthCard extends StatelessWidget {
  final String text;

  const GroundTruthCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      padding: const EdgeInsets.all(22.0),
      backgroundColor: AppColors.surface,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Icon(
              Icons.format_quote,
              size: 48.0,
              color: AppColors.primaryContainer.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 6.0),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Atkinson Hyperlegible Next',
                fontSize: 22.0,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
