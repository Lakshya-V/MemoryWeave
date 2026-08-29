import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_button.dart';

class QuizCompletionDialog extends StatelessWidget {
  final VoidCallback onReturnHome;

  const QuizCompletionDialog({super.key, required this.onReturnHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppDimensions.containerMargin),
      child: Container(
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppDimensions.roundedLarge,
          border: Border.all(color: AppColors.borderBlack, width: AppDimensions.thickBorderWidth),
          boxShadow: const [
            BoxShadow(
              color: AppColors.borderBlack,
              offset: Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer,
                border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
              ),
              child: const Icon(
                Icons.celebration,
                size: 56.0,
                color: AppColors.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              AppStrings.greatJob,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Atkinson Hyperlegible Next',
                fontSize: 30.0,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              AppStrings.completionSubtext,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Atkinson Hyperlegible Next',
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28.0),
            AccessibleButton.primary(
              text: AppStrings.returnHome,
              icon: Icons.home,
              onPressed: onReturnHome,
            ),
          ],
        ),
      ),
    );
  }
}
