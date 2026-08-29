import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/voice_record_button.dart';
import '../widgets/quiz_completion_dialog.dart';

class InteractiveQuizScreen extends StatefulWidget {
  const InteractiveQuizScreen({super.key});

  @override
  State<InteractiveQuizScreen> createState() => _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends State<InteractiveQuizScreen> {
  int _currentQuestionIndex = 2; // Question 2 of 5
  final int _totalQuestions = 5;
  bool _isRecording = false;
  String _statusText = AppStrings.tapToSpeak;
  Timer? _recordingTimer;

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _handleMicTap() {
    if (!_isRecording) {
      // Start recording simulation
      setState(() {
        _isRecording = true;
        _statusText = AppStrings.listening;
      });

      _recordingTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isRecording) {
          _finishRecording();
        }
      });
    } else {
      _finishRecording();
    }
  }

  void _finishRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _statusText = AppStrings.processing;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _statusText = 'Answer recorded!';
        });
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizCompletionDialog(
        onReturnHome: () {
          Navigator.of(context).pop(); // dismiss dialog
          Navigator.of(context).pop(); // return home
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentQuestionIndex / _totalQuestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.appName,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32.0, color: AppColors.primary),
            onPressed: () {},
            tooltip: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.containerMargin,
            vertical: 16.0,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Question progress bar
                Text(
                  'Question $_currentQuestionIndex of $_totalQuestions',
                  style: const TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  height: 16.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: AppColors.borderBlack, width: AppDimensions.borderWidth),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.stackGap),

                // Image Container with 4px black border
                Container(
                  width: double.infinity,
                  height: 240.0,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: AppDimensions.roundedLarge,
                    border: Border.all(color: AppColors.borderBlack, width: 4.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CustomPaint(
                      painter: _VintageWeddingPhotoPainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),

                // Question Speech Bubble
                const SpeechBubble(
                  text: AppStrings.sampleQuestion,
                ),
                const SizedBox(height: 32.0),

                // Voice Record Control
                VoiceRecordButton(
                  isRecording: _isRecording,
                  onTap: _handleMicTap,
                ),
                const SizedBox(height: 16.0),
                Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Atkinson Hyperlegible Next',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: _isRecording ? AppColors.error : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VintageWeddingPhotoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sepia/Greyscale background
    final bg = Paint()..color = const Color(0xFFE8E5DF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final dark = Paint()..color = const Color(0xFF2C2C2C);
    final mid = Paint()..color = const Color(0xFF7A7875);
    final white = Paint()..color = const Color(0xFFFDFCFA);

    // Couple silhouette / retro wedding illustration
    final cx = size.width / 2;
    final cy = size.height * 0.52;

    // Bride veil & dress
    final veil = Path()
      ..moveTo(cx - 50, cy - 30)
      ..quadraticBezierTo(cx - 70, cy + 40, cx - 60, cy + 90)
      ..lineTo(cx - 10, cy + 90)
      ..close();
    canvas.drawPath(veil, white);

    // Bride head & smile
    canvas.drawCircle(Offset(cx - 36, cy - 24), 22.0, Paint()..color = const Color(0xFFD3CECA));
    canvas.drawCircle(Offset(cx - 36, cy - 30), 20.0, dark); // hair

    // Groom suit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 36, cy + 32), width: 56, height: 80),
        const Radius.circular(8),
      ),
      dark,
    );
    // Groom tie & shirt
    final shirtPath = Path()
      ..moveTo(cx + 30, cy - 8)
      ..lineTo(cx + 42, cy - 8)
      ..lineTo(cx + 36, cy + 20)
      ..close();
    canvas.drawPath(shirtPath, white);

    // Groom head
    canvas.drawCircle(Offset(cx + 36, cy - 24), 22.0, Paint()..color = const Color(0xFFD3CECA));
    canvas.drawCircle(Offset(cx + 36, cy - 30), 20.0, dark); // groom hair

    // Bouquet
    canvas.drawCircle(Offset(cx - 20, cy + 40), 16.0, white);
    canvas.drawCircle(Offset(cx - 16, cy + 36), 8.0, mid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
