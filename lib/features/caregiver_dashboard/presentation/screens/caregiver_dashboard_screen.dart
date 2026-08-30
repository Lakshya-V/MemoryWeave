import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/widgets/accessible_card.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/metric_card.dart';
import '../widgets/cognitive_trend_graph.dart';
import '../widgets/memory_library_item_tile.dart';
import '../../data/models/memory_item.dart';
import '../../data/models/dashboard_service.dart';
import '../../../add_memory/presentation/screens/add_family_memory_screen.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  // TODO: replace with real logged-in user id once auth exists.
  final String userId;

  const CaregiverDashboardScreen({super.key, this.userId = 'user_default'});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

// How many memory tiles to show per "page" when the caregiver taps
// Load More — keeps the initial screen short and scrolling manageable.
const int _memoriesPageSize = 3;

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  bool _isLoading = true;
  String? _dashboardError;

  // Real fields from GET /caregiver/dashboard
  String _behavioralState = 'stable';
  String _clinicalInsight = '';
  int _totalSessions = 0;

  // Real memory list from GET /caregiver/memories.
  // Null = failed to load (old backend / network error); empty list =
  // loaded fine, caregiver just hasn't saved anything yet.
  List<MemoryItem>? _allMemories;
  int _visibleMemoryCount = _memoriesPageSize;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
      _dashboardError = null;
    });

    final results = await Future.wait([
      DashboardService.fetchDashboard(widget.userId),
      DashboardService.fetchMemories(),
    ]);

    if (!mounted) return;

    final dashboardData = results[0] as Map<String, dynamic>?;
    final memoriesData = results[1] as List<Map<String, dynamic>>?;

    setState(() {
      if (dashboardData != null) {
        _behavioralState = dashboardData['behavioral_state']?.toString() ?? 'stable';
        _clinicalInsight = dashboardData['clinical_insight']?.toString() ?? '';
        _totalSessions = (dashboardData['total_sessions'] as num?)?.toInt() ?? 0;
      } else {
        _dashboardError = 'Could not load session insights.';
      }

      _allMemories = memoriesData?.map((json) => MemoryItem.fromJson(json)).toList();
      _visibleMemoryCount = _memoriesPageSize;
      _isLoading = false;
    });
  }

  void _loadMoreMemories() {
    setState(() {
      _visibleMemoryCount =
          (_visibleMemoryCount + _memoriesPageSize).clamp(0, _allMemories?.length ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Eleanor'),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final memories = _allMemories ?? [];
    final visibleMemories = memories.take(_visibleMemoryCount).toList();
    final hasMore = _visibleMemoryCount < memories.length;

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
        child: RefreshIndicator(
          onRefresh: _fetchAll,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                        const SizedBox(height: AppDimensions.stackGap),

                        // --- Session insight card: state badge, session
                        // count, and clinical note grouped in ONE card
                        // instead of three loose floating pieces. ---
                        AccessibleCard(
                          padding: const EdgeInsets.all(16.0),
                          backgroundColor: AppColors.surface,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_dashboardError != null)
                                Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: AppColors.primary, size: 20.0),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        _dashboardError!,
                                        style: const TextStyle(fontFamily: 'Atkinson Hyperlegible Next', fontSize: 14.0),
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 12.0,
                                  runSpacing: 8.0,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: _behavioralStateColor(_behavioralState),
                                        borderRadius: AppDimensions.roundedFull,
                                        border: Border.all(color: AppColors.borderBlack, width: 1.5),
                                      ),
                                      child: Text(
                                        _behavioralState.replaceAll('_', ' ').toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'Atkinson Hyperlegible Next',
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$_totalSessions sessions total',
                                      style: const TextStyle(
                                        fontFamily: 'Atkinson Hyperlegible Next',
                                        fontSize: 14.0,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_clinicalInsight.isNotEmpty) ...[
                                  const SizedBox(height: 12.0),
                                  Text(
                                    _clinicalInsight,
                                    style: const TextStyle(
                                      fontFamily: 'Atkinson Hyperlegible Next',
                                      fontSize: 15.0,
                                      height: 1.4,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.stackGap),

                        // --- Metric cards: stacked, full width, consistent
                        // gap — no shared row to fight over space in. ---
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

                        const CognitiveTrendGraph(),
                        const SizedBox(height: AppDimensions.stackGap),

                        // --- Active Memory Library: real data ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              AppStrings.activeMemoryLibrary,
                              style: TextStyle(
                                fontFamily: 'Atkinson Hyperlegible Next',
                                fontSize: 24.0,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              '(${memories.length})',
                              style: const TextStyle(
                                fontFamily: 'Atkinson Hyperlegible Next',
                                fontSize: 17.0,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),

                        if (_allMemories == null)
                          // Backend doesn't have /caregiver/memories yet,
                          // or the request failed.
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppDimensions.roundedMedium,
                              border: Border.all(color: AppColors.borderBlack, width: 1.0),
                            ),
                            child: const Text(
                              "Couldn't load saved memories. Pull down to refresh and try again.",
                              style: TextStyle(fontFamily: 'Atkinson Hyperlegible Next', fontSize: 15.0),
                            ),
                          )
                        else if (memories.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppDimensions.roundedMedium,
                              border: Border.all(color: AppColors.borderBlack, width: 1.0),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.photo_library_outlined, size: 36.0, color: AppColors.outline),
                                SizedBox(height: 8.0),
                                Text(
                                  'No memories saved yet. Add one below to get started.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Atkinson Hyperlegible Next', fontSize: 15.0),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          ...visibleMemories.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: MemoryLibraryItemTile(item: item),
                            ),
                          ),
                          if (hasMore)
                            Center(
                              child: OutlinedButton(
                                onPressed: _loadMoreMemories,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceContainer,
                                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppDimensions.roundedLarge,
                                    side: const BorderSide(color: AppColors.borderBlack, width: 2.0),
                                  ),
                                ),
                                child: Text(
                                  '${AppStrings.loadMoreMemories} (${memories.length - _visibleMemoryCount} more)',
                                  style: const TextStyle(
                                    fontFamily: 'Atkinson Hyperlegible Next',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ),

              // --- FIXED: Bottom Sticky Action Container ---
              // Wrapped in SafeArea top:false to handle device bottom insets
              // and adjusted horizontal/vertical padding.
              SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.containerMargin,
                    vertical: 12.0,
                  ),
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
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddFamilyMemoryScreen(),
                            ),
                          );
                          _fetchAll();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _behavioralStateColor(String state) {
    switch (state) {
      case 'persistent_change':
        return AppColors.error;
      case 'temporary_deviation':
        return AppColors.primary;
      case 'stable':
      default:
        return AppColors.secondary;
    }
  }
}