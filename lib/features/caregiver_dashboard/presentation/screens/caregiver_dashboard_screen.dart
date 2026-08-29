import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/metric_card.dart';
import '../widgets/cognitive_trend_graph.dart';
import '../widgets/memory_library_item_tile.dart';
import '../../data/models/memory_item.dart';
import '../../../add_memory/presentation/screens/add_family_memory_screen.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  String _selectedTab = 'Daily';

  final List<MemoryItem> _memories = const [
    MemoryItem(
      id: '1',
      title: 'Goa Vacation 1998',
      dateAdded: 'Oct 12, 2023',
      contextDescription: 'This photo shows Sunita and Rohan at Goa beach during the summer of 2018. Eleanor is holding the red beach ball.',
      timesPrompted: 6,
      avgRecallAccuracy: 92,
    ),
    MemoryItem(
      id: '2',
      title: 'Buster in the Yard',
      dateAdded: 'Oct 05, 2023',
      contextDescription: 'Golden retriever Buster playing on the front lawn in summer 2021. Eleanor adopted him in spring.',
      timesPrompted: 4,
      avgRecallAccuracy: 88,
    ),
    MemoryItem(
      id: '3',
      title: "Sarah's Wedding",
      dateAdded: 'Sep 28, 2023',
      contextDescription: "Sarah and David's wedding in upstate New York in 1968. Eleanor was maid of honor.",
      timesPrompted: 8,
      avgRecallAccuracy: 85,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Eleanor',
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32.0, color: AppColors.primary),
            onPressed: () {},
            tooltip: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.containerMargin,
                  vertical: 16.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.eleanorsOverview,
                        style: TextStyle(
                          fontFamily: 'Atkinson Hyperlegible Next',
                          fontSize: 28.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Time Filter Tab Bar
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppDimensions.roundedLarge,
                          border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: ['Daily', 'Weekly', 'Monthly'].map((tab) {
                            final isSelected = _selectedTab == tab;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedTab = tab),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.surface : Colors.transparent,
                                  borderRadius: AppDimensions.roundedMedium,
                                  border: Border.all(
                                    color: isSelected ? AppColors.borderBlack : Colors.transparent,
                                    width: isSelected ? 2.0 : 0.0,
                                  ),
                                ),
                                child: Text(
                                  tab,
                                  style: TextStyle(
                                    fontFamily: 'Atkinson Hyperlegible Next',
                                    fontSize: 18.0,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.stackGap),

                      // Metric Cards Grid
                      const MetricCard(
                        title: AppStrings.avgAccuracy,
                        icon: Icons.check_circle_outline,
                        value: '88%',
                        badgeText: AppStrings.baselineComparison,
                        badgeIcon: Icons.trending_up,
                        badgeBackgroundColor: AppColors.secondary,
                        badgeForegroundColor: AppColors.onSecondary,
                      ),
                      const SizedBox(height: 16.0),
                      const MetricCard(
                        title: AppStrings.avgResponseSpeed,
                        icon: Icons.timer_outlined,
                        value: '2.4s',
                        badgeText: AppStrings.responsePaceInfo,
                        badgeIcon: Icons.info_outline,
                        badgeBackgroundColor: AppColors.surfaceContainer,
                        badgeForegroundColor: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppDimensions.stackGap),

                      // Cognitive Trend Graph
                      const CognitiveTrendGraph(),
                      const SizedBox(height: AppDimensions.stackGap),

                      // Active Memory Library Header
                      Row(
                        children: [
                          const Text(
                            AppStrings.activeMemoryLibrary,
                            style: TextStyle(
                              fontFamily: 'Atkinson Hyperlegible Next',
                              fontSize: 26.0,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            AppStrings.photoCount,
                            style: const TextStyle(
                              fontFamily: 'Atkinson Hyperlegible Next',
                              fontSize: 18.0,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Memory items
                      ..._memories.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: MemoryLibraryItemTile(item: item),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Load More Memories
                      Center(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainer,
                            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.roundedLarge,
                              side: const BorderSide(color: AppColors.borderBlack, width: 2.0),
                            ),
                          ),
                          child: const Text(
                            AppStrings.loadMoreMemories,
                            style: TextStyle(
                              fontFamily: 'Atkinson Hyperlegible Next',
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Sticky Action Button
            Container(
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600.0),
                  child: AccessibleButton.primary(
                    text: AppStrings.addNewMemoryImages,
                    icon: Icons.add_photo_alternate,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddFamilyMemoryScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
