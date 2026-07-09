import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

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
          'Chat History',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
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
                  IconsaxPlusLinear.clock,
                  size: 64.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                'No conversations yet',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                'Your past conversations with NAI\nwill appear here.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
