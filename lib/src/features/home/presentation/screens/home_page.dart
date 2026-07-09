import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import 'package:nai/src/features/auth/presentation/providers/session_provider.dart';
import 'package:nai/src/features/auth/presentation/providers/auth_provider.dart';

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
    // This method will be connected to the AI service layer.
    // See: lib/features/chat/domain/usecases/send_message.dart
    // See: lib/features/chat/data/repositories/chat_repository_impl.dart
    return 'Message received. AI response will be available after connecting the service layer.';
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
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                'NAI',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
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
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
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
              ? SizedBox(
                  width: 40.w,
                  child: Row(
                    children: [
                      _buildDot(),
                      SizedBox(width: 4.w),
                      _buildDot(),
                      SizedBox(width: 4.w),
                      _buildDot(),
                    ],
                  ),
                )
              : Text(
                  content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isUser
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant,
        shape: BoxShape.circle,
      ),
    );
  }
}
