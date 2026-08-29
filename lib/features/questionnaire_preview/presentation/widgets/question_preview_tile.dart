import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/accessible_card.dart';
import '../../data/models/generated_question.dart';

class QuestionPreviewTile extends StatelessWidget {
  final GeneratedQuestion question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const QuestionPreviewTile({
    super.key,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      padding: const EdgeInsets.all(20.0),
      boxShadow: const [
        BoxShadow(
          color: AppColors.onSurface,
          offset: Offset(4, 4),
          blurRadius: 0,
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${question.questionNumber}',
                  style: const TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  question.text,
                  style: const TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          Column(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit, size: 24.0, color: AppColors.onBackground),
                  onPressed: onEdit,
                  tooltip: 'Edit Question',
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete, size: 24.0, color: AppColors.error),
                  onPressed: onDelete,
                  tooltip: 'Delete Question',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
