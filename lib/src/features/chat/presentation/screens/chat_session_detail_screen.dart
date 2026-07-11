import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import 'package:nai/src/features/chat/presentation/providers/ai_engine_provider.dart';
import 'package:nai/src/features/chat/presentation/widgets/animated_reveal_text.dart';
import 'package:nai/src/features/chat/data/chat_history_store.dart';

import '../../domain/chat_message.dart';

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

  List<Map<String, String>> _buildHistory() {
    final recent = _messages.where((m) => m.id != 'typing').toList();
    final last10 = recent.length > 10 ? recent.sublist(recent.length - 10) : recent;
    return last10
        .map((m) => {'role': m.role == 'user' ? 'user' : 'assistant', 'content': m.content})
        .toList();
  }

  Future<void> _sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || _isProcessing) return;

    final history = _buildHistory();

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
      _messages.add(ChatMessage(id: 'typing', role: 'assistant', content: '...', timestamp: DateTime.now()));
    });
    _scrollToBottom();

    final aiEngine = ref.read(aiEngineProvider);
    final response = await aiEngine.respond(trimmed, history: history);

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
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.role == 'user';
                final isProcessing = _isProcessing && message.content == '...' && !isUser;

                if (isUser) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(AppSpacing.xl.w, AppSpacing.xs.h, AppSpacing.md.w, AppSpacing.xs.h),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                        padding: EdgeInsets.all(AppSpacing.md.w),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: AppBorders.md.copyWith(bottomRight: Radius.zero),
                        ),
                        child: Text(message.content, style: textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary)),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.sm.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14.r,
                            backgroundColor: colorScheme.primary,
                            child: Text('N',
                                style: TextStyle(
                                    color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                          ),
                          SizedBox(width: AppSpacing.sm.w),
                          Text('NAI', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      isProcessing
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onSurfaceVariant),
                            )
                          : AnimatedRevealText(
                              text: message.content,
                              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, height: 1.5),
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
                        border: OutlineInputBorder(borderRadius: AppBorders.lg, borderSide: BorderSide.none),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.sm.h),
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
                          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
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
