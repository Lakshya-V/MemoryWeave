import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/widgets/accessible_card.dart';
import '../data/add_memory_service.dart';
import '../widgets/photo_dropzone.dart';
import '../../../questionnaire_preview/presentation/screens/questionnaire_preview_screen.dart';

class AddFamilyMemoryScreen extends StatefulWidget {
  const AddFamilyMemoryScreen({super.key});

  @override
  State<AddFamilyMemoryScreen> createState() => _AddFamilyMemoryScreenState();
}

class _AddFamilyMemoryScreenState extends State<AddFamilyMemoryScreen> {
  bool _isGenerating = false;

  // Replace this with your actual uploaded image URL or dynamic controller input
  final String _sampleImageUrl = "https://example.com/family-photo.jpg"; //[cite: 1]

  Future<void> _triggerGeneration() async {
    if (_isGenerating) return;

    setState(() => _isGenerating = true);

    try {
      // 1. Call backend API to analyze image & get Reka AI questions[cite: 1]
      final questions = await AddMemoryService.generateQuestions(_sampleImageUrl);

      if (!mounted) return;

      if (questions != null && questions.isNotEmpty) {
        // 2. Navigate to Preview screen passing the fetched questions & image URL
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuestionnairePreviewScreen(
              imageUrl: _sampleImageUrl,
              questions: questions,
            ),
          ),
        );
      } else {
        // 3. Handle network error or empty response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate questions. Check API link or try again.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 32.0, color: AppColors.primary),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                  const Expanded(
                    child: Text(
                      AppStrings.addFamilyMemory,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Atkinson Hyperlegible Next',
                        fontSize: 26.0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48.0),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.containerMargin),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600.0),
                  child: Column(
                    children: [
                      PhotoDropzone(
  onTap: () {
    if (!_isGenerating) {
      _triggerGeneration();
    }
  },
),
                      const SizedBox(height: AppDimensions.stackGap),

                      // Context section with spinner
                      AccessibleCard(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isGenerating)
                              const SizedBox(
                                width: 48.0,
                                height: 48.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              )
                            else
                              Container(
                                width: 56.0,
                                height: 56.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.borderBlack, width: 3.0),
                                ),
                                child: const Center(
                                  child: Icon(Icons.psychology, size: 32.0, color: AppColors.primary),
                                ),
                              ),
                            const SizedBox(height: 20.0),
                            Text(
                              _isGenerating ? "Analyzing photo with AI..." : AppStrings.creatingQuestionnaire,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Atkinson Hyperlegible Next',
                                fontSize: 26.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Actions
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
                    AccessibleButton.outlined(
                      text: AppStrings.addMorePhotos,
                      icon: Icons.add,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12.0),
                    AccessibleButton.primary(
                      text: _isGenerating ? "Generating..." : AppStrings.saveAndGenerate,
                      onPressed: _isGenerating ? null : _triggerGeneration,
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