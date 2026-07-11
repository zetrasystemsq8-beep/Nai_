import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import 'package:nai/src/features/auth/presentation/providers/session_provider.dart';
import 'package:nai/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:nai/src/features/chat/presentation/providers/ai_engine_provider.dart';
import 'package:nai/src/features/chat/data/chat_history_store.dart';
import 'package:nai/src/features/chat/data/rate_limiter.dart';
import 'package:nai/src/features/chat/domain/chat_message.dart';
import 'package:nai/src/features/chat/presentation/widgets/animated_reveal_text.dart';
import 'package:nai/src/features/chat/presentation/widgets/message_action_bar.dart';
import 'package:nai/src/features/challenges/presentation/providers/challenge_provider.dart';

// Screens
import 'package:nai/src/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:nai/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:nai/src/features/chat/presentation/screens/chat_history_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  Key _historyKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    final screens = [
      const _ChatTabContent(),
      ChatHistoryScreen(key: _historyKey),
      const ChallengesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedIndex = index;
            if (index == 1) {
              _historyKey = UniqueKey();
            }
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(IconsaxPlusLinear.message), label: 'Chat'),
          NavigationDestination(icon: Icon(IconsaxPlusLinear.clock), label: 'History'),
          NavigationDestination(icon: Icon(IconsaxPlusLinear.cup), label: 'Challenges'),
          NavigationDestination(icon: Icon(IconsaxPlusLinear.setting), label: 'Settings'),
        ],
      ),
    );
  }
}

const List<String> _suggestedPrompts = [
  "What's happening in Nigeria today?",
  "Explain how blockchain works",
  "Give me a business idea for Nigeria",
  "Help me write a CV summary",
];

class _ChatTabContent extends ConsumerStatefulWidget {
  const _ChatTabContent();

  @override
  ConsumerState<_ChatTabContent> createState() => _ChatTabContentState();
}

class _ChatTabContentState extends ConsumerState<_ChatTabContent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final _historyStore = ChatHistoryStore();
  final _rateLimiter = RateLimiter();
  bool _isProcessing = false;
  bool _showScrollToBottom = false;

  late String _sessionId;

  @override
  void initState() {
    super.initState();
    _sessionId = const Uuid().v4();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isNearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;
    if (_showScrollToBottom == isNearBottom) {
      setState(() => _showScrollToBottom = !isNearBottom);
    }
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

  void _startNewChat() {
    HapticFeedback.mediumImpact();
    setState(() {
      _messages.clear();
      _sessionId = const Uuid().v4();
    });
  }

  /// Builds recent conversation turns in the {role, content} format Groq
  /// expects, so short follow-ups are understood in context.
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

    final canSend = await _rateLimiter.canSendMessage();
    if (!canSend) {
      final minutesLeft = await _rateLimiter.getMinutesUntilReset();
      if (mounted) {
        showGlobalToast(
          message: "You've reached your hourly message limit. Try again in $minutesLeft minutes.",
          status: 'error',
        );
      }
      return;
    }

    HapticFeedback.lightImpact();

    final history = _buildHistory();

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: 'user',
      content: trimmed,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isProcessing = true;
    });
    _messageController.clear();
    _scrollToBottom();

    setState(() {
      _messages.add(ChatMessage(id: 'typing', role: 'assistant', content: '...', timestamp: DateTime.now()));
    });
    _scrollToBottom();

    await _rateLimiter.recordMessageSent();

    final gameProgress = ref.read(gameProgressProvider);
    await gameProgress.recordQuestionAsked();

    final aiEngine = ref.read(aiEngineProvider);
    final response = await aiEngine.respond(trimmed, history: history);

    final assistantMessage = ChatMessage(
      id: const Uuid().v4(),
      role: 'assistant',
      content: response,
      timestamp: DateTime.now(),
    );

    setState(() {
      if (_messages.isNotEmpty && _messages.last.id == 'typing') {
        _messages.removeLast();
      }
      _messages.add(assistantMessage);
      _isProcessing = false;
    });
    HapticFeedback.selectionClick();
    _scrollToBottom();

    await _saveSession();
  }

  Future<void> _regenerate(int assistantIndex) async {
    if (_isProcessing) return;

    final canSend = await _rateLimiter.canSendMessage();
    if (!canSend) {
      final minutesLeft = await _rateLimiter.getMinutesUntilReset();
      if (mounted) {
        showGlobalToast(
          message: "You've reached your hourly message limit. Try again in $minutesLeft minutes.",
          status: 'error',
        );
      }
      return;
    }

    int userIndex = assistantIndex - 1;
    if (userIndex < 0 || _messages[userIndex].role != 'user') return;
    final userQuery = _messages[userIndex].content;
    final historyBeforeThis = _messages.sublist(0, userIndex).where((m) => m.id != 'typing').toList();
    final history = historyBeforeThis
        .map((m) => {'role': m.role == 'user' ? 'user' : 'assistant', 'content': m.content})
        .toList();

    setState(() {
      _isProcessing = true;
      _messages[assistantIndex] = _messages[assistantIndex].copyWith(content: '...');
    });

    await _rateLimiter.recordMessageSent();

    final aiEngine = ref.read(aiEngineProvider);
    final response = await aiEngine.respond(userQuery, history: history);

    setState(() {
      _messages[assistantIndex] = _messages[assistantIndex].copyWith(content: response);
      _isProcessing = false;
    });

    await _saveSession();
  }

  void _setReaction(int index, MessageReaction reaction) {
    HapticFeedback.selectionClick();
    setState(() {
      _messages[index] = _messages[index].copyWith(reaction: reaction);
    });
    _saveSession();
  }

  Future<void> _saveSession() async {
    if (_messages.isEmpty) return;

    final firstUserMessage = _messages.firstWhere((m) => m.role == 'user', orElse: () => _messages.first);
    final title = firstUserMessage.content.length > 40
        ? '${firstUserMessage.content.substring(0, 40)}...'
        : firstUserMessage.content;

    await _historyStore.saveSession(
      ChatSession(
        id: _sessionId,
        title: title,
        createdAt: _messages.first.timestamp,
        messages: List.of(_messages),
      ),
    );
  }

  void _showTimestamp(DateTime timestamp) {
    final formatted = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sent at $formatted'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundColor: colorScheme.primary,
              child: Text('N',
                  style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12.sp)),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Text('NAI Assistant',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(IconsaxPlusLinear.add_circle),
            tooltip: 'New Chat',
            onPressed: _messages.isEmpty ? null : _startNewChat,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUser = message.role == 'user';
                          final isProcessing = _isProcessing && message.content == '...' && !isUser;

                          return _ChatBubble(
                            isUser: isUser,
                            message: message,
                            isProcessing: isProcessing,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            onReact: isUser ? null : (reaction) => _setReaction(index, reaction),
                            onReload: isUser || isProcessing ? null : () => _regenerate(index),
                            onLongPress: () => _showTimestamp(message.timestamp),
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
                            hintText: 'Ask me about Nigeria...',
                            border: OutlineInputBorder(borderRadius: AppBorders.lg, borderSide: BorderSide.none),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.sm.h),
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
          if (_showScrollToBottom)
            Positioned(
              right: AppSpacing.md.w,
              bottom: 90.h,
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                child: const Icon(Icons.arrow_downward),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xl.w),
              decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(IconsaxPlusLinear.message, size: 64.sp, color: colorScheme.primary),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text('NAI - Nigeria\'s AI Assistant',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            SizedBox(height: AppSpacing.sm.h),
            Text('Ask me anything about Nigeria.\nI\'m here to help! 🇳🇬',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            SizedBox(height: AppSpacing.xl.h),
            Wrap(
              spacing: AppSpacing.sm.w,
              runSpacing: AppSpacing.sm.h,
              alignment: WrapAlignment.center,
              children: _suggestedPrompts.map((prompt) {
                return ActionChip(
                  label: Text(prompt, style: textTheme.bodySmall),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _sendMessage(prompt);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== CHAT BUBBLE — full-width, document-style for AI, compact for user =====
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.isUser,
    required this.message,
    required this.isProcessing,
    required this.colorScheme,
    required this.textTheme,
    required this.onReact,
    required this.onReload,
    required this.onLongPress,
  });

  final bool isUser;
  final ChatMessage message;
  final bool isProcessing;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final ValueChanged<MessageReaction>? onReact;
  final VoidCallback? onReload;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      // User messages stay compact, right-aligned — like a normal sent text.
      return Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.xl.w, AppSpacing.xs.h, AppSpacing.md.w, AppSpacing.xs.h),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onLongPress: onLongPress,
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
        ),
      );
    }

    // AI messages: full width, document-style, no bubble background.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.sm.h),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AiAvatar(colorScheme: colorScheme),
                SizedBox(width: AppSpacing.sm.w),
                Text('NAI', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: AppSpacing.sm.h),
            isProcessing
                ? const _TypingIndicator()
                : AnimatedRevealText(
                    text: message.content,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, height: 1.5),
                  ),
            if (!isProcessing && onReact != null && onReload != null)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs.h),
                child: MessageActionBar(
                  content: message.content,
                  reaction: message.reaction,
                  onReact: onReact!,
                  onReload: onReload!,
                  colorScheme: colorScheme,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  const _AiAvatar({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14.r,
      backgroundColor: colorScheme.primary,
      child: Text('N', style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12.sp)),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return SizedBox(
      width: 40.w,
      height: 16.h,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final delay = i * 0.2;
              final t = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
              final scale = 0.5 + 0.5 * (t < 0.5 ? t * 2 : (1 - t) * 2);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(color: colorScheme.onSurfaceVariant, shape: BoxShape.circle),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
