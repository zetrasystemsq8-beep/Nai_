import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import 'package:nai/src/features/chat/presentation/providers/ai_engine_provider.dart';
import 'package:nai/src/features/chat/presentation/widgets/markdown_message.dart';
import 'package:nai/src/features/chat/presentation/widgets/message_action_bar.dart';
import 'package:nai/src/features/chat/data/chat_history_store.dart';

import '../../domain/chat_message.dart';

/// Opens a past conversation and lets the user continue chatting in it —
/// not a read-only view. Saves back to the same session ID on every message.
class ChatSessionDetailScreen extends ConsumerStatefulWidget {
  const ChatSessionDetailScreen({super.key, required this.session});

  final ChatSession session;

  @override
  ConsumerState<ChatSessionDetailScreen> createState() => _ChatSessionDetailScreenState();
}

class _ChatSessionDetailScreenState extends ConsumerState<ChatSessionDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _historyStore = ChatHistoryStore();
  late List<ChatMessage> _messages;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.session.messages);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || _isProcessing) return;

    setState(() {
      _messages.add(ChatMessage(
        id: 'temp-user-${DateTime.now().millisecondsSinceEpoch}',
        role: 'user',
        content: trimmed,
        timestamp: DateTime.now(),
      ));
      _isProcessing = true;
    });
    _messageController.clear();
    _scrollToBottom();

    setState(() {
      _messages.add(ChatMessage(
        id: 'typing',
        role: 'assistant',
        content: '...',
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();

    final aiEngine = ref.read(aiEngineProvider);
    final response = await aiEngine.respond(trimmed);

    setState(() {
      if (_messages.isNotEmpty && _messages.last.id == 'typing') {
        _messages.removeLast();
      }
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      ));
      _isProcessing = false;
    });
    _scrollToBottom();

    await _historyStore.saveSession(
      ChatSession(
        id: widget.session.id,
        title: widget.session.title,
        createdAt: widget.session.createdAt,
        messages: List.of(_messages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Scaffold(
      appBar: AppTopBar(title: widget.session.title),
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(AppSpacing.md.w),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.role == 'user';
                final isProcessing = _isProcessing && message.content == '...' && !isUser;
                final bubbleRadius = AppBorders.md.topLeft;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: AppSpacing.sm.h,
                    left: isUser ? AppSpacing.xl.w : 0,
                    right: isUser ? 0 : AppSpacing.xl.w,
                  ),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          radius: 14.r,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            'N',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs.w),
                      ],
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.72,
                          ),
                          padding: EdgeInsets.all(AppSpacing.md.w),
                          decoration: BoxDecoration(
                            color: isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                            borderRadius: AppBorders.md.copyWith(
                              bottomLeft: isUser ? bubbleRadius : Radius.zero,
                              bottomRight: isUser ? Radius.zero : bubbleRadius,
                            ),
                          ),
                          child: isProcessing
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : isUser
                                  ? Text(
                                      message.content,
                                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary),
                                    )
                                  : MarkdownMessage(
                                      content: message.content,
                                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
                                    ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.sm.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 120.h),
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isProcessing,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Continue the conversation...',
                        border: OutlineInputBorder(
                          borderRadius: AppBorders.lg,
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md.w,
                          vertical: AppSpacing.sm.h,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                IconButton.filled(
                  onPressed: _isProcessing ? null : () => _sendMessage(_messageController.text),
                  icon: _isProcessing
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                        )
                      : const Icon(IconsaxPlusLinear.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
