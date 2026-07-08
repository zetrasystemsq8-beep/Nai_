import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

class ChatHistoryList extends ConsumerWidget {
  final List<dynamic> messages;
  final ScrollController? scrollController;
  final bool isLoading;

  const ChatHistoryList({
    super.key,
    required this.messages,
    this.scrollController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.theme.colorScheme;

    if (messages.isEmpty && !isLoading) {
      return Center(
        child: AppEmptyState(
          title: 'No Messages',
          subtitle: 'Start a conversation to see messages here',
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
      itemCount: messages.length + (isLoading ? 1 : 0),
      reverse: true,
      itemBuilder: (context, index) {
        if (isLoading && index == 0) {
          return Padding(
            padding: EdgeInsets.all(AppSpacing.md.w),
            child: const AppLoading(),
          );
        }

        final messageIndex = isLoading ? index - 1 : index;
        final message = messages[messageIndex];

        return _MessageBubbleWidget(
          message: message,
        );
      },
    );
  }
}

class _MessageBubbleWidget extends StatelessWidget {
  final dynamic message;

  const _MessageBubbleWidget({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    final isUser = message.role == 'user';
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isUser
        ? colorScheme.primary
        : colorScheme.surfaceVariant;
    final textColor = isUser
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.xs.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomLeft: Radius.circular(isUser ? 12.r : 2.r),
            bottomRight: Radius.circular(isUser ? 2.r : 12.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content ?? 'Message',
              style: textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              message.timestamp?.toIso8601String().split('T').last.substring(0, 5) ?? '',
              style: textTheme.labelSmall?.copyWith(
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
