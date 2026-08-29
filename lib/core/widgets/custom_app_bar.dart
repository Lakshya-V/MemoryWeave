import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Top App Bar matching the 2px solid black border bottom and high contrast
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBottomBorder;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBottomBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: showBottomBorder
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.borderBlack,
                  width: AppDimensions.borderWidth,
                ),
              )
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SizedBox(
            height: AppDimensions.touchTargetMin,
            child: Row(
              children: [
                if (leading != null)
                  leading!
                else if (Navigator.of(context).canPop())
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 32.0, color: AppColors.primary),
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Back',
                  )
                else
                  const SizedBox(width: 48.0),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Atkinson Hyperlegible Next',
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (actions != null) ...actions! else const SizedBox(width: 48.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.touchTargetMin);
}
