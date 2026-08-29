import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/ground_truth_card.dart';
import '../widgets/metadata_info_tile.dart';
import '../../../caregiver_dashboard/data/models/memory_item.dart';

class MemoryDetailsScreen extends StatefulWidget {
  final MemoryItem? item;

  const MemoryDetailsScreen({super.key, this.item});

  @override
  State<MemoryDetailsScreen> createState() => _MemoryDetailsScreenState();
}

class _MemoryDetailsScreenState extends State<MemoryDetailsScreen> {
  bool _isRecordingContext = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item ??
        const MemoryItem(
          id: '1',
          title: 'Goa Vacation 1998',
          dateAdded: 'Aug 12, 2026',
          contextDescription: AppStrings.groundTruthQuote,
          timesPrompted: 6,
          avgRecallAccuracy: 92,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Memory Details...',
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 32.0, color: AppColors.primary),
            onPressed: () {},
            tooltip: 'Options',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.containerMargin),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // High-quality Photo Image Container
                Container(
                  width: double.infinity,
                  height: 220.0,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: AppDimensions.roundedLarge,
                    border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CustomPaint(
                      painter: _GoaBeachDetailPainter(),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.stackGap),

                // Ground Truth Section
                const Text(
                  AppStrings.groundTruthTitle,
                  style: TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 26.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12.0),
                GroundTruthCard(
                  text: item.contextDescription,
                ),
                const SizedBox(height: AppDimensions.stackGap),

                // Metadata list
                MetadataInfoTile(
                  icon: Icons.calendar_today,
                  label: 'Date Uploaded: ${item.dateAdded}',
                ),
                const SizedBox(height: 12.0),
                MetadataInfoTile(
                  icon: Icons.repeat,
                  label: 'Times Prompted: ${item.timesPrompted} times',
                ),
                const SizedBox(height: 12.0),
                MetadataInfoTile(
                  icon: Icons.check_circle,
                  iconColor: AppColors.secondary,
                  label: 'Avg. Recall Accuracy: ${item.avgRecallAccuracy}%',
                ),
                const SizedBox(height: 32.0),

                // Action Footer
                AccessibleButton.outlined(
                  text: _isRecordingContext ? 'Recording Audio...' : AppStrings.recordAdditionalContext,
                  icon: _isRecordingContext ? Icons.stop : Icons.mic,
                  onPressed: () {
                    setState(() {
                      _isRecordingContext = !_isRecordingContext;
                    });
                    if (!_isRecordingContext) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Additional context audio recorded and synchronized.'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoaBeachDetailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.45), Paint()..color = const Color(0xFF4FC3F7));
    // Ocean
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.2), Paint()..color = const Color(0xFF0288D1));
    // Golden Sand
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.65, size.width, size.height * 0.35), Paint()..color = const Color(0xFFFFD54F));

    // Sunita, Rohan, and Eleanor standing smiling
    final skin = Paint()..color = const Color(0xFFD7CCC8);
    final darkCloth = Paint()..color = const Color(0xFF37474F);
    final blueCloth = Paint()..color = const Color(0xFF1976D2);
    final childCloth = Paint()..color = const Color(0xFFEF5350);

    final cx = size.width / 2;
    final cy = size.height * 0.55;

    // Sunita (Mom, left)
    canvas.drawCircle(Offset(cx - 50, cy - 24), 16.0, skin);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - 50, cy + 24), width: 36, height: 64), const Radius.circular(6)),
      darkCloth,
    );

    // Rohan (Dad, right)
    canvas.drawCircle(Offset(cx + 50, cy - 26), 16.0, skin);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 50, cy + 24), width: 38, height: 66), const Radius.circular(6)),
      blueCloth,
    );

    // Eleanor (Child, center with red ball)
    canvas.drawCircle(Offset(cx, cy - 4), 14.0, skin);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 34), width: 26, height: 48), const Radius.circular(4)),
      childCloth,
    );

    // Red beach ball in hands
    canvas.drawCircle(Offset(cx, cy + 28), 12.0, Paint()..color = const Color(0xFFD32F2F));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
