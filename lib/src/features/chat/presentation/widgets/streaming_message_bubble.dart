import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

class StreamingMessageBubble extends StatefulWidget {
  final Stream<String> messageStream;
  final VoidCallback? onComplete;

  const StreamingMessageBubble({
    super.key,
    required this.messageStream,
    this.onComplete,
  });

  @override
  State<StreamingMessageBubble> createState() => _StreamingMessageBubbleState();
}

class _StreamingMessageBubbleState extends State<StreamingMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final StringBuffer _buffer = StringBuffer();
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.xs.h,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.sm.h,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
              bottomLeft: Radius.circular(2.r),
              bottomRight: Radius.circular(12.r),
            ),
          ),
          child: StreamBuilder<String>(
            stream: widget.messageStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _buffer.write(snapshot.data);
              }

              if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                );
              }

              final isStreaming = !snapshot.hasData &&
                  !snapshot.isDone &&
                  _buffer.isEmpty;
              final isDone = snapshot.isDone;

              if (isDone && !_isComplete) {
                _isComplete = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onComplete?.call();
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_buffer.isNotEmpty)
                    Text(
                      _buffer.toString(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  if (isStreaming)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Typing',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs.w),
                        _TypingIndicator(
                          dotColor: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final Color dotColor;

  const _TypingIndicator({required this.dotColor});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.2,
                0.6 + index * 0.2,
                curve: Curves.easeInOut,
              ),
            ),
          ),
          child: Container(
            width: 6.w,
            height: 6.w,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              color: widget.dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
