import 'dart:async';
import 'package:flutter/material.dart';

/// Reveals [text] progressively, word by word, to simulate the model
/// "typing" its answer — instead of the full response appearing instantly.
class AnimatedRevealText extends StatefulWidget {
  const AnimatedRevealText({
    super.key,
    required this.text,
    required this.style,
    this.onUpdate,
  });

  final String text;
  final TextStyle? style;
  final VoidCallback? onUpdate;

  @override
  State<AnimatedRevealText> createState() => _AnimatedRevealTextState();
}

class _AnimatedRevealTextState extends State<AnimatedRevealText> {
  late final List<String> _words;
  int _visibleWordCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    _startReveal();
  }

  void _startReveal() {
    // A few words at a time reads more naturally than one-by-one and
    // finishes quickly even for long answers.
    const wordsPerTick = 3;
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (_visibleWordCount >= _words.length) {
        timer.cancel();
        return;
      }
      setState(() {
        _visibleWordCount = (_visibleWordCount + wordsPerTick).clamp(0, _words.length);
      });
      widget.onUpdate?.call();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleText = _words.take(_visibleWordCount).join(' ');
    return Text(visibleText, style: widget.style);
  }
}
