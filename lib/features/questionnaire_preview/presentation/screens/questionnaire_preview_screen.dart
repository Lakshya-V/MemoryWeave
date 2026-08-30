import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../add_memory/presentation/data/add_memory_service.dart';
import '../widgets/reference_memory_card.dart';
import '../widgets/question_preview_tile.dart';
import '../../data/models/generated_question.dart';

class QuestionnairePreviewScreen extends StatefulWidget {
  final String? imageUrl;
  final List<String>? questions;

  const QuestionnairePreviewScreen({
    super.key,
    this.imageUrl,
    this.questions,
  });

  @override
  State<QuestionnairePreviewScreen> createState() =>
      _QuestionnairePreviewScreenState();
}

class _QuestionnairePreviewScreenState extends State<QuestionnairePreviewScreen> {
  List<GeneratedQuestion> _questions = [];
  final Map<int, TextEditingController> _controllers = {};
  bool _isSaving = false;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _populateQuestions();
  }

  void _populateQuestions() {
    final rawList = (widget.questions != null && widget.questions!.isNotEmpty)
        ? widget.questions!
        : [
            'Who are the people present in this photo?',
            'Where was this photo taken?',
            'What special memory or event is captured here?'
          ];

    _questions = rawList.asMap().entries.map((entry) {
      final qId = entry.key + 1;
      _controllers[qId] = TextEditingController();
      return GeneratedQuestion(
        id: qId,
        questionNumber: qId,
        text: entry.value,
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleApprove() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No photo attached to this memory.')),
      );
      return;
    }
    final targetUrl = widget.imageUrl!;

    // Map UI questions & text controllers to the backend QA Pair structure
    final qaPairs = _questions.map((q) {
      final answerText = _controllers[q.id]?.text.trim();
      return {
        'question': q.text,
        'answer': (answerText != null && answerText.isNotEmpty)
            ? answerText
            : 'Family memory reference',
      };
    }).toList();

    final success = await AddMemoryService.saveMemory(
      targetUrl,
      qaPairs,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memory saved to database and added to quiz rotation!'),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save memory. Check terminal logs.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _handleRegenerate() async {
    if (_isRegenerating) return;

    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No photo attached to this memory.')),
      );
      return;
    }
    final targetUrl = widget.imageUrl!;

    setState(() => _isRegenerating = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Regenerating questions with Reka AI...'),
        backgroundColor: AppColors.primaryContainer,
      ),
    );

    final newQuestions = await AddMemoryService.generateQuestions(targetUrl);

    if (!mounted) return;

    setState(() => _isRegenerating = false);

    if (newQuestions != null && newQuestions.isNotEmpty) {
      setState(() {
        _questions = newQuestions.asMap().entries.map((entry) {
          final qId = entry.key + 1;
          _controllers[qId] ??= TextEditingController();
          return GeneratedQuestion(
            id: qId,
            questionNumber: qId,
            text: entry.value,
          );
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to regenerate questions. Try again or check backend logs.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
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
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              QuestionPreviewTile(
                                question: q,
                                onEdit: () {},
                                onDelete: () {
                                  setState(() {
                                    _questions.removeWhere((item) => item.id == q.id);
                                    _controllers[q.id]?.dispose();
                                    _controllers.remove(q.id);
                                  });
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextField(
                                controller: _controllers[q.id],
                                decoration: InputDecoration(
                                  labelText: 'Ground Truth Answer ${q.questionNumber}',
                                  hintText: 'e.g., My daughter Sarah at Goa Beach',
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderBlack,
                    width: AppDimensions.borderWidth,
                  ),
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AccessibleButton.primary(
                      text: _isSaving ? "Saving..." : AppStrings.approveAndAddToQuiz,
                      icon: Icons.check_circle,
                      onPressed: (_isSaving || _isRegenerating) ? null : _handleApprove,
                    ),
                    const SizedBox(height: 12.0),
                    AccessibleButton.outlined(
                      text: _isRegenerating ? "Generating..." : AppStrings.regenerateQuestions,
                      icon: Icons.refresh,
                      onPressed: (_isSaving || _isRegenerating) ? null : _handleRegenerate,
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