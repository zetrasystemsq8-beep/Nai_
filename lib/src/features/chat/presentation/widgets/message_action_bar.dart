import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/chat_message.dart';

class MessageActionBar extends StatefulWidget {
  const MessageActionBar({
    super.key,
    required this.content,
    required this.reaction,
    required this.onReact,
    required this.onReload,
    required this.colorScheme,
  });

  final String content;
  final MessageReaction reaction;
  final ValueChanged<MessageReaction> onReact;
  final VoidCallback onReload;
  final ColorScheme colorScheme;

  @override
  State<MessageActionBar> createState() => _MessageActionBarState();
}

class _MessageActionBarState extends State<MessageActionBar> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
      );
    }
  }

  Future<void> _share() async {
    await Share.share(widget.content);
  }

  Future<void> _togglePlay() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _tts.speak(widget.content);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        _ActionIcon(icon: Icons.copy_outlined, color: iconColor, onTap: _copy),
        _ActionIcon(icon: Icons.share_outlined, color: iconColor, onTap: _share),
        _ActionIcon(
          icon: _isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
          color: iconColor,
          onTap: _togglePlay,
        ),
        _ActionIcon(
          icon: Icons.refresh,
          color: iconColor,
          onTap: widget.onReload,
        ),
        _ActionIcon(
          icon: Icons.thumb_up_outlined,
          filled: widget.reaction == MessageReaction.liked,
          color: widget.reaction == MessageReaction.liked
              ? widget.colorScheme.primary
              : iconColor,
          onTap: () => widget.onReact(
            widget.reaction == MessageReaction.liked
                ? MessageReaction.none
                : MessageReaction.liked,
          ),
        ),
        _ActionIcon(
          icon: Icons.thumb_down_outlined,
          filled: widget.reaction == MessageReaction.disliked,
          color: widget.reaction == MessageReaction.disliked
              ? widget.colorScheme.error
              : iconColor,
          onTap: () => widget.onReact(
            widget.reaction == MessageReaction.disliked
                ? MessageReaction.none
                : MessageReaction.disliked,
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
