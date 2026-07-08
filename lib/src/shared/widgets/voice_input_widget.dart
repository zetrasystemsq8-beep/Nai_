import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

class VoiceInputWidget extends StatefulWidget {
  final ValueChanged<String>? onTranscription;
  final VoidCallback? onStart;
  final VoidCallback? onStop;

  const VoiceInputWidget({
    super.key,
    this.onTranscription,
    this.onStart,
    this.onStop,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      widget.onStart?.call();
      showGlobalToast(
        message: 'Voice input started',
        status: 'info',
      );
    } else {
      widget.onStop?.call();
      showGlobalToast(
        message: 'Voice input stopped',
        status: 'success',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return GestureDetector(
      onTap: _toggleListening,
      child: _isListening
          ? ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.error,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.error.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    IconsaxPlusBold.microphone_2,
                    color: colorScheme.onError,
                    size: 24.sp,
                  ),
                ),
              ),
            )
          : Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
              ),
              child: Center(
                child: Icon(
                  IconsaxPlusLinear.microphone_2,
                  color: colorScheme.onPrimary,
                  size: 24.sp,
                ),
              ),
            ),
    );
  }
}
