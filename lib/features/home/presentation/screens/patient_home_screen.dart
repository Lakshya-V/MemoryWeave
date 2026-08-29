import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/pill_reminder_banner.dart';
import '../widgets/today_quiz_hero_card.dart';
import '../../../quiz/presentation/screens/interactive_quiz_screen.dart';
import '../../../caregiver_dashboard/presentation/screens/caregiver_dashboard_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  Timer? _holdTimer;
  Timer? _tickerTimer;
  double _progress = 0.0;
  bool _isHolding = false;
  static const int _holdDurationMs = 1000;

  void _startHolding() {
    setState(() {
      _isHolding = true;
      _progress = 0.0;
    });

    final startTime = DateTime.now();
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      if (mounted) {
        setState(() {
          _progress = (elapsed / _holdDurationMs).clamp(0.0, 1.0);
        });
      }
    });

    _holdTimer = Timer(const Duration(milliseconds: _holdDurationMs), () {
      _stopHolding();
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CaregiverDashboardScreen(),
          ),
        );
      }
    });
  }

  void _stopHolding() {
    _holdTimer?.cancel();
    _tickerTimer?.cancel();
    if (mounted) {
      setState(() {
        _isHolding = false;
        _progress = 0.0;
      });
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _tickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(2000.0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderBlack,
                width: AppDimensions.borderWidth,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MemoryWeave',
                    style: TextStyle(
                      fontFamily: 'Atkinson Hyperlegible Next',
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (_) => _startHolding(),
                    onTapUp: (_) => _stopHolding(),
                    onTapCancel: () => _stopHolding(),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderBlack, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                        color: AppColors.surfaceContainerLow,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_progress > 0.0)
                            Positioned.fill(
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progress,
                                child: Container(
                                  color: AppColors.secondaryContainer.withOpacity(0.85),
                                ),
                              ),
                            ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
                            child: Text(
                              'Caregiver',
                              style: TextStyle(
                                fontFamily: 'Atkinson Hyperlegible Next',
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  AppStrings.welcomeBack,
                  style: TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 28.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12.0),
                const PillReminderBanner(),
                const SizedBox(height: 12.0),
                TodayQuizHeroCard(
                  onStartQuiz: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InteractiveQuizScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
