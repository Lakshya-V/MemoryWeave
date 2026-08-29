import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_card.dart';
import '../../data/models/memory_item.dart';
import '../../../memory_details/presentation/screens/memory_details_screen.dart';

class MemoryLibraryItemTile extends StatelessWidget {
  final MemoryItem item;

  const MemoryLibraryItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      padding: const EdgeInsets.all(16.0),
      backgroundColor: AppColors.surface,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MemoryDetailsScreen(item: item),
          ),
        );
      },
      child: Row(
        children: [
          // Photo thumbnail
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: AppDimensions.roundedMedium,
              border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: CustomPaint(
                painter: _MemoryThumbnailPainter(title: item.title),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    const Icon(Icons.event, size: 16.0, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4.0),
                    Text(
                      'Added: ${item.dateAdded}',
                      style: const TextStyle(
                        fontFamily: 'Atkinson Hyperlegible Next',
                        fontSize: 15.0,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          // Show context action
          IconButton(
            icon: const Icon(Icons.info_outline, size: 28.0, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MemoryDetailsScreen(item: item),
                ),
              );
            },
            tooltip: AppStrings.showContext,
          ),
        ],
      ),
    );
  }
}

class _MemoryThumbnailPainter extends CustomPainter {
  final String title;

  _MemoryThumbnailPainter({required this.title});

  @override
  void paint(Canvas canvas, Size size) {
    if (title.contains('Goa')) {
      // Beach scene
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.6), Paint()..color = const Color(0xFF90CAF9));
      canvas.drawRect(Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4), Paint()..color = const Color(0xFFFFE082));
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), 8.0, Paint()..color = const Color(0xFFBA1A1A)); // red ball
    } else if (title.contains('Buster')) {
      // Yard dog scene
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.5), Paint()..color = const Color(0xFFBBDEFB));
      canvas.drawRect(Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5), Paint()..color = const Color(0xFFA5D6A7));
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.6), 14.0, Paint()..color = const Color(0xFFFFB74D)); // golden dog
    } else {
      // Placeholder image icon
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFEEEEEE));
      final iconPaint = Paint()
        ..color = const Color(0xFF74777F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(Rect.fromLTWH(18, 18, size.width - 36, size.height - 36), iconPaint);
      canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), 4.0, iconPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
