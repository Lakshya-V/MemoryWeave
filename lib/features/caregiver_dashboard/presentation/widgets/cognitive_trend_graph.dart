import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_card.dart';

class CognitiveTrendGraph extends StatelessWidget {
  const CognitiveTrendGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      padding: const EdgeInsets.all(20.0),
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.responseTrendTitle,
            style: TextStyle(
              fontFamily: 'Atkinson Hyperlegible Next',
              fontSize: 22.0,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
            height: 240.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppDimensions.roundedMedium,
              border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
            ),
            child: Stack(
              children: [
                // Baseline dashed line
                Positioned(
                  top: 100.0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 12.0),
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        color: AppColors.surfaceContainerLowest,
                        child: const Text(
                          AppStrings.personalBaseline,
                          style: TextStyle(
                            fontFamily: 'Atkinson Hyperlegible Next',
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomPaint(
                          painter: _DashedLinePainter(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chart Curve
                CustomPaint(
                  size: const Size(double.infinity, 240.0),
                  painter: _TrendChartPainter(),
                ),

                // Cognitive Drift Alert Badge
                Positioned(
                  top: 36.0,
                  left: 16.0,
                  right: 16.0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: AppDimensions.roundedSmall,
                        border: Border.all(color: AppColors.error, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33BA1A1A),
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 20.0, color: AppColors.onErrorContainer),
                          SizedBox(width: 6.0),
                          Text(
                            AppStrings.cognitiveDriftAlert,
                            style: TextStyle(
                              fontFamily: 'Atkinson Hyperlegible Next',
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Weekday labels
                Positioned(
                  bottom: 8.0,
                  left: 12.0,
                  right: 12.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map(
                          (day) => Text(
                            day,
                            style: const TextStyle(
                              fontFamily: 'Atkinson Hyperlegible Next',
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.outline,
                            ),
                          ),
                        )
                        .toList(),
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

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outlineVariant
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Line coordinates representing healthy baseline then anomaly drift on Friday
    path.moveTo(16.0, height * 0.72);
    path.quadraticBezierTo(width * 0.2, height * 0.65, width * 0.4, height * 0.68);
    path.quadraticBezierTo(width * 0.55, height * 0.66, width * 0.7, height * 0.35); // drift peak
    path.quadraticBezierTo(width * 0.85, height * 0.45, width - 16.0, height * 0.50);

    final linePaint = Paint()
      ..color = AppColors.primaryContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Anomaly Dot
    final dotCenter = Offset(width * 0.7, height * 0.35);
    final anomalyPaint = Paint()..color = AppColors.error;
    canvas.drawCircle(dotCenter, 6.0, anomalyPaint);
    canvas.drawCircle(dotCenter, 9.0, Paint()..color = AppColors.error.withValues(alpha: 0.3));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
