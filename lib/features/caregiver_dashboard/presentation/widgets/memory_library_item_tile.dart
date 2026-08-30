import 'dart:convert';
import 'dart:typed_data';
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Real photo thumbnail (falls back to a placeholder icon if
          // there's no image or it fails to load/decode).
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
              ),
              child: _buildThumbnail(),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    const Icon(Icons.event, size: 15.0, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        'Added: ${item.dateAdded}',
                        style: const TextStyle(
                          fontFamily: 'Atkinson Hyperlegible Next',
                          fontSize: 14.0,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (item.timesPrompted > 0) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    'Prompted ${item.timesPrompted}x · ${item.avgRecallAccuracy}% avg recall',
                    style: const TextStyle(
                      fontFamily: 'Atkinson Hyperlegible Next',
                      fontSize: 13.0,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4.0),
          // Show context action
          IconButton(
            icon: const Icon(Icons.info_outline, size: 26.0, color: AppColors.primary),
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

  Widget _buildThumbnail() {
    final url = item.imageUrl;
    if (url == null || url.isEmpty) {
      return const Center(
        child: Icon(Icons.image_outlined, color: AppColors.outline, size: 32.0),
      );
    }

    // Backend stores images as base64 data URIs (see AddMemoryService),
    // so decode those directly rather than trying to hit them as a network URL.
    if (url.startsWith('data:image')) {
      try {
        final base64Part = url.substring(url.indexOf(',') + 1);
        final bytes = base64Decode(base64Part);
        return Image.memory(
          Uint8List.fromList(bytes),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => const Center(
            child: Icon(Icons.broken_image_outlined, color: AppColors.outline, size: 32.0),
          ),
        );
      } catch (_) {
        return const Center(
          child: Icon(Icons.broken_image_outlined, color: AppColors.outline, size: 32.0),
        );
      }
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Center(
          child: Icon(Icons.broken_image_outlined, color: AppColors.outline, size: 32.0),
        ),
      );
    }

    return const Center(
      child: Icon(Icons.image_outlined, color: AppColors.outline, size: 32.0),
    );
  }
}