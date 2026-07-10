import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownMessage extends StatelessWidget {
  const MarkdownMessage({super.key, required this.content, required this.style});

  final String content;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: style,
        strong: style?.copyWith(fontWeight: FontWeight.bold),
        em: style?.copyWith(fontStyle: FontStyle.italic),
        code: style?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: Colors.black.withValues(alpha: 0.08),
        ),
        listBullet: style,
        h1: style?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        h2: style?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        h3: style?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
