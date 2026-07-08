import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import '../../domain/entities/chat_session.dart';

class ChatSessionCard extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;

  const ChatSessionCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    final lastMessage = session.messages.isNotEmpty
        ? session.messages.last.content
        : 'No messages';

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.card,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: AppBorders.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              lastMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              session.updatedAt.formatDate(),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
