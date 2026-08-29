import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quiz/presentation/screens/interactive_quiz_screen.dart';
import '../../../caregiver_dashboard/presentation/screens/caregiver_dashboard_screen.dart';

class AppDrawer extends StatelessWidget {
  final String activeRoute;

  const AppDrawer({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DrawerItem(
                title: AppStrings.home,
                icon: Icons.home,
                isSelected: activeRoute == 'home',
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 16.0),
              _DrawerItem(
                title: AppStrings.quiz,
                icon: Icons.psychology,
                isSelected: activeRoute == 'quiz',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const InteractiveQuizScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
              _DrawerItem(
                title: AppStrings.settings,
                icon: Icons.settings,
                isSelected: activeRoute == 'settings',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CaregiverDashboardScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.roundedMedium,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: AppDimensions.roundedMedium,
          border: Border.all(
            color: isSelected ? AppColors.borderBlack : Colors.transparent,
            width: AppDimensions.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32.0,
              color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
            ),
            const SizedBox(width: 16.0),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Atkinson Hyperlegible Next',
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
