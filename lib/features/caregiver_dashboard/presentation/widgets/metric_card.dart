import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/accessible_card.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String badgeText;
  final IconData badgeIcon;
  final Color badgeBackgroundColor;
  final Color badgeForegroundColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.badgeText,
    required this.badgeIcon,
    this.badgeBackgroundColor = AppColors.secondary,
    this.badgeForegroundColor = AppColors.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      padding: const EdgeInsets.all(20.0),
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded so a long title wraps/truncates gracefully instead
              // of pushing into or overlapping the icon next to it.
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(icon, color: AppColors.outline, size: 28.0),
            ],
          ),
          const SizedBox(height: 14.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 44.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 14.0),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: badgeBackgroundColor,
                    borderRadius: AppDimensions.roundedFull,
                    border: Border.all(color: AppColors.borderBlack, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 18.0, color: badgeForegroundColor),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontFamily: 'Atkinson Hyperlegible Next',
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: badgeForegroundColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}