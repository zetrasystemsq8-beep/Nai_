import 'package:uuid/uuid.dart';

import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import 'package:nai/src/features/auth/presentation/providers/session_provider.dart';
import 'package:nai/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:nai/src/features/chat/presentation/providers/ai_engine_provider.dart';
import 'package:nai/src/features/chat/data/chat_history_store.dart';
import 'package:nai/src/features/chat/domain/chat_message.dart';
import 'package:nai/src/features/chat/presentation/widgets/animated_reveal_text.dart';

// Screens
import 'package:nai/src/features/nigeria/presentation/screens/nigeria_news_screen.dart';
import 'package:nai/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:nai/src/features/chat/presentation/screens/chat_history_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _ChatTabContent(),
      const ChatHistoryScreen(),
      const NigeriaNewsScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(IconsaxPlusLinear.message),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(IconsaxPlusLinear.clock),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(IconsaxPlusLinear.document),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(IconsaxPlusLinear.setting),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ===== CHAT TAB CONTENT =====
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
  bool _isProcessing = false;

  late final String _sessionId;

  @override
  void initState() {
    super.initState();
    _sessionId = const Uuid().v4();
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
      _messages.add(ChatMessage(
        id: 'typing',
        role: 'assistant',
        content: '...',
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();

    final response = await _processMessage(trimmed);

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
    _scrollToBottom();

    await _saveSession();
  }

  Future<void> _saveSession() async {
    if (_messages.isEmpty) return;

    final firstUserMessage = _messages.firstWhere(
      (m) => m.role == 'user',
      orElse: () => _messages.first,
    );
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

  Future<String> _processMessage(String message) async {
    final aiEngine = ref.read(aiEngineProvider);
    return aiEngine.respond(message);
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
              child: Text(
                'N',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Text(
              'NAI Assistant',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(AppSpacing.md.w),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message.role == 'user';
                      final isProcessing = _isProcessing &&
                          index == _messages.length - 1 &&
                          !isUser;

                      return _ChatBubble(
                        isUser: isUser,
                        content: message.content,
                        isProcessing: isProcessing,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      );
                    },
                  ),
          ),

          // Input Field
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md.w,
              vertical: AppSpacing.sm.h,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
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
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusLinear.message,
                size: 64.sp,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              'NAI - Nigeria\'s AI Assistant',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              'Ask me anything about Nigeria.\nI\'m here to help! 🇳🇬',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== CHAT BUBBLE WIDGET =====
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.isUser,
    required this.content,
    required this.isProcessing,
    required this.colorScheme,
    required this.textTheme,
  });

  final bool isUser;
  final String content;
  final bool isProcessing;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
            _AiAvatar(colorScheme: colorScheme),
            SizedBox(width: AppSpacing.xs.w),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: EdgeInsets.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color: isUser
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: AppBorders.md.copyWith(
                  bottomLeft: isUser ? bubbleRadius : Radius.zero,
                  bottomRight: isUser ? Radius.zero : bubbleRadius,
                ),
              ),
              child: isProcessing
                  ? const _TypingIndicator()
                  : isUser
                      ? Text(
                          content,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : AnimatedRevealText(
                          text: content,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== AI AVATAR =====
class _AiAvatar extends StatelessWidget {
  const _AiAvatar({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
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
    );
  }
}

// ===== ANIMATED TYPING INDICATOR =====
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
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
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
