import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/accessible_button.dart';

class QuizCompletionDialog extends StatelessWidget {
  final int score;
  final String feedback;
  final bool anomalyFlagged;
  final VoidCallback onNext;
  final VoidCallback onReturnHome;

  const QuizCompletionDialog({
    super.key,
    required this.score,
    required this.feedback,
    required this.anomalyFlagged,
    required this.onNext,
    required this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.roundedLarge,
        side: const BorderSide(
          color: AppColors.borderBlack,
          width: AppDimensions.borderWidth,
        ),
      ),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              anomalyFlagged ? Icons.warning_amber_rounded : Icons.stars_rounded,
              size: 56.0,
              color: anomalyFlagged ? AppColors.error : AppColors.secondary,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Accuracy Score: $score%',
              style: const TextStyle(
                fontFamily: 'Atkinson Hyperlegible Next',
                fontSize: 24.0,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              feedback,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Atkinson Hyperlegible Next',
                fontSize: 16.0,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24.0),
            AccessibleButton.primary(
              text: 'Next Question',
              onPressed: onNext,
            ),
            const SizedBox(height: 8.0),
            AccessibleButton.outlined(
              text: 'Return Home',
              onPressed: onReturnHome,
            ),
          ],
        ),
      ),
    );
  }
}