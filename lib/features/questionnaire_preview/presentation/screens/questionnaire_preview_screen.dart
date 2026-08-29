import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/reference_memory_card.dart';
import '../widgets/question_preview_tile.dart';
import '../../data/models/generated_question.dart';

class QuestionnairePreviewScreen extends StatefulWidget {
  const QuestionnairePreviewScreen({super.key});

  @override
  State<QuestionnairePreviewScreen> createState() => _QuestionnairePreviewScreenState();
}

class _QuestionnairePreviewScreenState extends State<QuestionnairePreviewScreen> {
  List<GeneratedQuestion> _questions = [
    const GeneratedQuestion(id: 1, questionNumber: 1, text: 'Who is holding the red beach ball?'),
    const GeneratedQuestion(id: 2, questionNumber: 2, text: 'What year was this photo taken?'),
    const GeneratedQuestion(id: 3, questionNumber: 3, text: 'Where was the family vacationing?'),
    const GeneratedQuestion(id: 4, questionNumber: 4, text: 'What color is the striped towel on the sand?'),
  ];

  void _handleApprove() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Questions approved and added to active quiz rotation!'),
        backgroundColor: AppColors.secondary,
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleRegenerate() {
    setState(() {
      _questions = [
        const GeneratedQuestion(id: 1, questionNumber: 1, text: 'Who is smiling next to Eleanor on the shore?'),
        const GeneratedQuestion(id: 2, questionNumber: 2, text: 'What season was this trip taken in?'),
        const GeneratedQuestion(id: 3, questionNumber: 3, text: 'What game were you playing with the beach ball?'),
        const GeneratedQuestion(id: 4, questionNumber: 4, text: 'Who booked the beachside cottage?'),
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Questions regenerated using Reka AI ground truth.'),
        backgroundColor: AppColors.primaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: AppStrings.careConnect,
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
                        AppStrings.questionnairePreview,
                        style: TextStyle(
                          fontFamily: 'Atkinson Hyperlegible Next',
                          fontSize: 28.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const ReferenceMemoryCard(),
                      const SizedBox(height: AppDimensions.stackGap),

                      ..._questions.map(
                        (q) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: QuestionPreviewTile(
                            question: q,
                            onEdit: () {},
                            onDelete: () {
                              setState(() {
                                _questions.removeWhere((item) => item.id == q.id);
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AccessibleButton.primary(
                      text: AppStrings.approveAndAddToQuiz,
                      icon: Icons.check_circle,
                      onPressed: _handleApprove,
                    ),
                    const SizedBox(height: 12.0),
                    AccessibleButton.outlined(
                      text: AppStrings.regenerateQuestions,
                      icon: Icons.refresh,
                      onPressed: _handleRegenerate,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
