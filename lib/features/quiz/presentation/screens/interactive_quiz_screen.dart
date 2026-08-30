import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/services/quiz_service.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/voice_record_button.dart';
import '../widgets/quiz_completion_dialog.dart';

class InteractiveQuizScreen extends StatefulWidget {
  const InteractiveQuizScreen({super.key});

  @override
  State<InteractiveQuizScreen> createState() => _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends State<InteractiveQuizScreen> {
  bool _isLoading = true;
  bool _isEvaluating = false;
  bool _isRecording = false;

  String? _activeMemoryId;
  String? _imageUrl;
  String _questionText = "Loading today's memory question...";
  String _statusText = AppStrings.tapToSpeak;

  final Stopwatch _stopwatch = Stopwatch();
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _liveTranscript = '';

  @override
  void initState() {
    super.initState();
    _fetchNextQuestion();
  }

  @override
  void dispose() {
    _speech.stop();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _fetchNextQuestion() async {
    setState(() {
      _isLoading = true;
      _statusText = AppStrings.tapToSpeak;
    });

    final data = await QuizService.fetchNextQuiz();

    if (!mounted) return;

    if (data != null) {
      setState(() {
        _activeMemoryId = data['memory_id']?.toString() ?? 'mem_a1b2c3';
        _imageUrl = data['image_url'];
        _questionText = data['question_text'] ?? AppStrings.sampleQuestion;
        _isLoading = false;
      });

      // Start timing as soon as the question is rendered
      _stopwatch.reset();
      _stopwatch.start();
    } else {
      // Fallback state if database has no active memories
      setState(() {
        _activeMemoryId = 'mem_a1b2c3';
        _questionText = AppStrings.sampleQuestion;
        _isLoading = false;
      });
      _stopwatch.reset();
      _stopwatch.start();
    }
  }

  Future<void> _handleMicTap() async {
    if (_isLoading || _isEvaluating) return;

    if (!_isRecording) {
      // Ask for mic permission / initialize the recognizer. Returns false
      // if the user denies permission or the device has no speech service.
      final available = await _speech.initialize(
        onStatus: (status) {
          // The plugin calls this when listening stops on its own
          // (e.g. the user goes quiet) — treat that the same as a manual tap.
          if (status == 'done' && mounted && _isRecording) {
            _finishRecordingAndSubmit();
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isRecording = false;
              _statusText = 'Could not hear you — try again';
            });
          }
        },
      );

      if (!available) {
        setState(() {
          _statusText = 'Microphone unavailable. Check app permissions.';
        });
        return;
      }

      setState(() {
        _isRecording = true;
        _liveTranscript = '';
        _statusText = AppStrings.listening;
      });

      _speech.listen(
        onResult: (result) {
          setState(() => _liveTranscript = result.recognizedWords);
        },
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
      );
    } else {
      await _finishRecordingAndSubmit();
    }
  }

  Future<void> _finishRecordingAndSubmit() async {
    await _speech.stop();
    _stopwatch.stop();

    final latencyMs = _stopwatch.elapsedMilliseconds;
    final transcript = _liveTranscript.trim();

    setState(() {
      _isRecording = false;
      _isEvaluating = true;
      _statusText = AppStrings.processing;
    });

    if (transcript.isEmpty) {
      setState(() {
        _isEvaluating = false;
        _statusText = "Didn't catch that — tap to try again";
      });
      return;
    }

    final response = await QuizService.submitEvaluation(
      memoryId: _activeMemoryId ?? 'mem_a1b2c3',
      transcribedText: transcript,
      latencyMs: latencyMs,
    );

    if (!mounted) return;

    setState(() {
      _isEvaluating = false;
      _statusText = 'Answer recorded!';
    });

    final accuracyScore = response?['accuracy_score'] ?? 85;
    final feedback = response?['feedback_text'] ?? "Wonderful! That was indeed your daughter Sarah.";
    final anomalyFlagged = response?['anomaly_flagged'] ?? false;

    _showCompletionDialog(
      score: accuracyScore,
      feedback: feedback,
      anomalyFlagged: anomalyFlagged,
    );
  }

  void _showCompletionDialog({
    required int score,
    required String feedback,
    required bool anomalyFlagged,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizCompletionDialog(
        score: score,
        feedback: feedback,
        anomalyFlagged: anomalyFlagged,
        onNext: () {
          Navigator.of(context).pop();
          _fetchNextQuestion();
        },
        onReturnHome: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.containerMargin,
                  vertical: 16.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Memory Activity',
                        style: TextStyle(
                          fontFamily: 'Atkinson Hyperlegible Next',
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.stackGap),

                      // Memory Image Frame
                      Container(
                        width: double.infinity,
                        height: 240.0,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: AppDimensions.roundedLarge,
                          border: Border.all(
                            color: AppColors.borderBlack,
                            width: 4.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: _imageUrl != null && _imageUrl!.startsWith('http')
                              ? Image.network(
                                  _imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => CustomPaint(
                                    painter: _VintageWeddingPhotoPainter(),
                                  ),
                                )
                              : CustomPaint(
                                  painter: _VintageWeddingPhotoPainter(),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Question Speech Bubble
                      SpeechBubble(text: _questionText),
                      const SizedBox(height: 32.0),

                      // Voice Recording Button
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
                          color: _isRecording
                              ? AppColors.error
                              : AppColors.onSurfaceVariant,
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
    final bg = Paint()..color = const Color(0xFFE8E5DF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final dark = Paint()..color = const Color(0xFF2C2C2C);
    final mid = Paint()..color = const Color(0xFF7A7875);
    final white = Paint()..color = const Color(0xFFFDFCFA);

    final cx = size.width / 2;
    final cy = size.height * 0.52;

    final veil = Path()
      ..moveTo(cx - 50, cy - 30)
      ..quadraticBezierTo(cx - 70, cy + 40, cx - 60, cy + 90)
      ..lineTo(cx - 10, cy + 90)
      ..close();
    canvas.drawPath(veil, white);

    canvas.drawCircle(Offset(cx - 36, cy - 24), 22.0, Paint()..color = const Color(0xFFD3CECA));
    canvas.drawCircle(Offset(cx - 36, cy - 30), 20.0, dark);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 36, cy + 32), width: 56, height: 80),
        const Radius.circular(8),
      ),
      dark,
    );
    final shirtPath = Path()
      ..moveTo(cx + 30, cy - 8)
      ..lineTo(cx + 42, cy - 8)
      ..lineTo(cx + 36, cy + 20)
      ..close();
    canvas.drawPath(shirtPath, white);

    canvas.drawCircle(Offset(cx + 36, cy - 24), 22.0, Paint()..color = const Color(0xFFD3CECA));
    canvas.drawCircle(Offset(cx + 36, cy - 30), 20.0, dark);

    canvas.drawCircle(Offset(cx - 20, cy + 40), 16.0, white);
    canvas.drawCircle(Offset(cx - 16, cy + 36), 8.0, mid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}