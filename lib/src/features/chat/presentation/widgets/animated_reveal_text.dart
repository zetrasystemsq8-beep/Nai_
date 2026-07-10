import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Reveals [text] progressively, then renders as markdown once complete.
class AnimatedRevealText extends StatefulWidget {
  const AnimatedRevealText({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  State<AnimatedRevealText> createState() => _AnimatedRevealTextState();
}

class _AnimatedRevealTextState extends State<AnimatedRevealText> {
  late final List<String> _words;
  int _visibleWordCount = 0;
  Timer? _timer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    _startReveal();
  }

  void _startReveal() {
    // Scale speed with length so long answers don't take forever, but
    // still feel progressive rather than instant.
    final wordsPerTick = (_words.length / 60).clamp(2, 8).round();
    _timer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (_visibleWordCount >= _words.length) {
        timer.cancel();
        setState(() => _done = true);
        return;
      }
      setState(() {
        _visibleWordCount = (_visibleWordCount + wordsPerTick).clamp(0, _words.length);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return MarkdownBody(
        data: widget.text,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: widget.style,
          strong: widget.style?.copyWith(fontWeight: FontWeight.bold),
          em: widget.style?.copyWith(fontStyle: FontStyle.italic),
          code: widget.style?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Colors.black.withValues(alpha: 0.08),
          ),
          listBullet: widget.style,
        ),
      );
    }
    final visibleText = _words.take(_visibleWordCount).join(' ');
    return Text(visibleText, style: widget.style);
  }
}
