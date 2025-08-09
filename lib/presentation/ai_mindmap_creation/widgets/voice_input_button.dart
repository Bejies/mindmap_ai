import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onTranscriptionComplete;
  final VoidCallback? onRecordingStart;
  final VoidCallback? onRecordingStop;

  const VoiceInputButton({
    super.key,
    required this.onTranscriptionComplete,
    this.onRecordingStart,
    this.onRecordingStop,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(), path: 'recording.m4a');
        setState(() {
          _isRecording = true;
        });
        _pulseController.repeat(reverse: true);
        widget.onRecordingStart?.call();
        HapticFeedback.mediumImpact();
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });
      _pulseController.stop();
      widget.onRecordingStop?.call();
      HapticFeedback.lightImpact();

      // Simulate transcription processing
      await Future.delayed(const Duration(seconds: 2));

      // Mock transcription result
      const mockTranscription =
          "Create a mindmap for planning my vacation to Japan including budget, activities, and accommodation";

      setState(() {
        _isProcessing = false;
      });

      widget.onTranscriptionComplete(mockTranscription);
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
      _showErrorSnackBar('Failed to process recording');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission'),
        content: const Text(
            'Please grant microphone permission to use voice input for mindmap creation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: _isProcessing
          ? null
          : (_isRecording ? _stopRecording : _startRecording),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 12.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _isRecording
                    ? colorScheme.error
                    : _isProcessing
                        ? colorScheme.secondary
                        : colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        (_isRecording ? colorScheme.error : colorScheme.primary)
                            .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: _isProcessing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onSecondary,
                          ),
                        ),
                      )
                    : CustomIconWidget(
                        iconName: _isRecording ? 'stop' : 'mic',
                        color: colorScheme.onPrimary,
                        size: 24,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
