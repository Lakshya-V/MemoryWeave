import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class SpeechBubble extends StatelessWidget {
  final String text;

  const SpeechBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Arrow pointing up
        CustomPaint(
          size: const Size(24.0, 12.0),
          painter: _BubbleTrianglePainter(),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppDimensions.roundedLarge,
            border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Atkinson Hyperlegible Next',
              fontSize: 26.0,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = AppColors.surfaceContainerLowest
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.borderBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppDimensions.borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);

    final borderPath = Path();
    borderPath.moveTo(0, size.height);
    borderPath.lineTo(size.width / 2, 0);
    borderPath.lineTo(size.width, size.height);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
