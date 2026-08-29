import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class VoiceRecordButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const VoiceRecordButton({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.isRecording ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isRecording ? AppColors.error : AppColors.primaryContainer,
                border: Border.all(
                  color: widget.isRecording ? AppColors.error : AppColors.borderBlack,
                  width: 4.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isRecording
                        ? AppColors.error.withValues(alpha: 0.4)
                        : AppColors.primaryContainer.withValues(alpha: 0.3),
                    blurRadius: widget.isRecording ? 24.0 : 12.0,
                    spreadRadius: widget.isRecording ? 6.0 : 2.0,
                  ),
                ],
              ),
              child: Icon(
                widget.isRecording ? Icons.mic : Icons.mic_none,
                size: 64.0,
                color: widget.isRecording ? AppColors.onError : AppColors.onPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
