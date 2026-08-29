import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_card.dart';

class ReferenceMemoryCard extends StatelessWidget {
  final String title;
  final String description;

  const ReferenceMemoryCard({
    super.key,
    this.title = 'Family Beach Vacation',
    this.description = AppStrings.questionsGenerated,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      padding: const EdgeInsets.all(16.0),
      boxShadow: const [
        BoxShadow(
          color: AppColors.onSurface,
          offset: Offset(4, 4),
          blurRadius: 0,
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84.0,
            height: 84.0,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: AppDimensions.roundedMedium,
              border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: CustomPaint(
                painter: _BeachPhotoPainter(),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 16.0,
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeachPhotoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.55), Paint()..color = const Color(0xFF81D4FA));
    // Sand
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45), Paint()..color = const Color(0xFFFFE082));
    // Family silhouettes
    final paint = Paint()..color = const Color(0xFF2E384D);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.4), 8.0, paint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.42), 7.0, paint);
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.55), 5.0, paint);
    // Red beach ball
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.65), 7.0, Paint()..color = const Color(0xFFD32F2F));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
