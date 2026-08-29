import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_card.dart';

class TodayQuizHeroCard extends StatelessWidget {
  final VoidCallback onStartQuiz;

  const TodayQuizHeroCard({super.key, required this.onStartQuiz});

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      backgroundColor: AppColors.primaryContainer,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Illustration / Image frame
          Container(
            height: 140.0,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppDimensions.roundedMedium,
              border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _FamilyIllustrationPainter(),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Text(
                        '5 Questions',
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          const Text(
            AppStrings.todayMemoryQuiz,
            style: TextStyle(
              fontFamily: 'Atkinson Hyperlegible Next',
              fontSize: 24.0,
              fontWeight: FontWeight.w800,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 14.0),
          Container(
            height: 58.0,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppDimensions.roundedMedium,
              border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppDimensions.roundedMedium,
                onTap: onStartQuiz,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      size: 30.0,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      AppStrings.startQuizNow,
                      style: TextStyle(
                        fontFamily: 'Atkinson Hyperlegible Next',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Warm background
    final bgPaint = Paint()..color = const Color(0xFFF7F3E9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Decorative foliage and shapes
    final greenPaint = Paint()..color = const Color(0xFF88D982).withValues(alpha: 0.6);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 60.0, greenPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.6), 70.0, greenPaint);

    // Family silhouettes / abstract warm characters
    final navyPaint = Paint()..color = const Color(0xFF001F3F);
    final accentPaint = Paint()..color = const Color(0xFF1B6D24);
    final skinPaint = Paint()..color = const Color(0xFFE2C4A2);

    // Center couple / family
    final cx = size.width / 2;
    final cy = size.height * 0.55;

    // Person 1 (left)
    canvas.drawCircle(Offset(cx - 38, cy - 26), 18.0, skinPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 38, cy + 28), width: 36, height: 60),
        const Radius.circular(10),
      ),
      navyPaint,
    );

    // Person 2 (right)
    canvas.drawCircle(Offset(cx + 38, cy - 28), 18.0, skinPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 38, cy + 28), width: 38, height: 62),
        const Radius.circular(10),
      ),
      accentPaint,
    );

    // Child in center
    canvas.drawCircle(Offset(cx, cy - 8), 14.0, skinPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 36), width: 28, height: 44),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFD4E3FF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
