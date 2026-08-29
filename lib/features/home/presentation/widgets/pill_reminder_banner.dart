import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/widgets/accessible_card.dart';

class PillReminderBanner extends StatefulWidget {
  const PillReminderBanner({super.key});

  @override
  State<PillReminderBanner> createState() => _PillReminderBannerState();
}

class _PillReminderBannerState extends State<PillReminderBanner> {
  bool _isTaken = false;

  @override
  Widget build(BuildContext context) {
    if (_isTaken) {
      return AccessibleCard(
        backgroundColor: AppColors.secondaryContainer,
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.secondary, size: 36.0),
            const SizedBox(width: 16.0),
            const Expanded(
              child: Text(
                'Morning medicine marked as taken! Well done.',
                style: TextStyle(
                  fontFamily: 'Atkinson Hyperlegible Next',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.undo, color: AppColors.onSecondaryContainer),
              onPressed: () => setState(() => _isTaken = false),
            )
          ],
        ),
      );
    }

    return AccessibleCard(
      backgroundColor: AppColors.warningContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.medication,
                size: 32.0,
                color: AppColors.primary,
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'Did you take your morning medicine?',
                  style: TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          AccessibleButton.success(
            text: 'Yes, I did',
            icon: Icons.check_circle,
            height: 52.0,
            onPressed: () {
              setState(() {
                _isTaken = true;
              });
            },
          ),
        ],
      ),
    );
  }
}
