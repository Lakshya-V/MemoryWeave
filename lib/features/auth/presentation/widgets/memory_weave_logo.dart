import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// MemoryWeave Brand Logo Icon
class MemoryWeaveLogo extends StatelessWidget {
  final double size;

  const MemoryWeaveLogo({super.key, this.size = 110.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: CustomPaint(
            painter: _WeaveKnotPainter(),
          ),
        ),
        const SizedBox(height: 6.0),
        const Text(
          'MemoryWeave',
          style: TextStyle(
            fontFamily: 'Atkinson Hyperlegible Next',
            fontSize: 22.0,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _WeaveKnotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.22;

    // Draw infinity knot symbol
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(center.dx - r * 0.7, center.dy), radius: r));
    path.addOval(Rect.fromCircle(center: Offset(center.dx + r * 0.7, center.dy), radius: r));
    canvas.drawPath(path, paint);

    // Decorative inner node
    final nodePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
