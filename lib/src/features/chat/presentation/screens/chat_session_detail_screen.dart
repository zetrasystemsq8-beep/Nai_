import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import '../../domain/chat_message.dart';

/// Read-only view of a past chat session.
class ChatSessionDetailScreen extends StatelessWidget {
  const ChatSessionDetailScreen({super.key, required this.session});

  final ChatSession session;

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
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md.w),
        itemCount: session.messages.length,
        itemBuilder: (context, index) {
          final message = session.messages[index];
          final isUser = message.role == 'user';
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
                      color: isUser
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: AppBorders.md.copyWith(
                        bottomLeft: isUser ? bubbleRadius : Radius.zero,
                        bottomRight: isUser ? Radius.zero : bubbleRadius,
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
