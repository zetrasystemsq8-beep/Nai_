import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import 'package:nai/src/features/auth/presentation/providers/session_provider.dart';
import 'package:nai/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:nai/src/features/chat/presentation/providers/ai_engine_provider.dart';

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
      body: _screens[_selectedIndex],
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
  final List<Map<String, String>> _messages = [];
  bool _isProcessing = false;

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
    if (message.trim().isEmpty || _isProcessing) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message.trim()});
      _isProcessing = true;
    });
    _messageController.clear();
    _scrollToBottom();

    setState(() {
      _messages.add({'role': 'assistant', 'content': '...'});
    });
    _scrollToBottom();

    final response = await _processMessage(message);

    setState(() {
      if (_messages.isNotEmpty && _messages.last['role'] == 'assistant') {
        _messages.removeLast();
      }
      _messages.add({'role': 'assistant', 'content': response});
      _isProcessing = false;
    });
    _scrollToBottom();
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
            Image.asset(
              'assets/icons/nai_logo.png',
              width: 28,
              height: 28,
            ),
            SizedBox(width: AppSpacing.sm.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NAI',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  "Nigeria's AI Assistant",
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ],
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
                      final isUser = message['role'] == 'user';
                      final content = message['content'] ?? '';
                      final isProcessing = _isProcessing &&
                          index == _messages.length - 1 &&
                          !isUser;

                      return _ChatBubble(
                        isUser: isUser,
                        content: content,
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
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isProcessing,
                    decoration: InputDecoration(
                      hintText: 'Message NAI...',
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
                    onSubmitted: (value) => _sendMessage(value),
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
              child: Image.asset(
                'assets/icons/nai_logo.png',
                width: 64,
                height: 64,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              'Welcome to NAI',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              "Nigeria's AI Assistant\n\nAsk anything.\nSearch the web.\nUnderstand Nigeria.\nWrite, code and learn with AI.",
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
                  : Text(
                      content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
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
      child: Image.asset(
        'assets/icons/nai_logo.png',
        width: 24,
        height: 24,
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
