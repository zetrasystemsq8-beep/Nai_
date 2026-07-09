import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import '../providers/daily_briefing_provider.dart';
import '../providers/news_provider.dart';

class NigeriaNewsScreen extends ConsumerWidget {
  const NigeriaNewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final briefingAsync = ref.watch(dailyBriefingProvider);
    final latestNewsAsync = ref.watch(latestNewsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Today's Briefing",
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyBriefingProvider);
          ref.invalidate(latestNewsProvider);
        },
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md.w),
          children: [
            // Daily AI briefing card
            Container(
              padding: EdgeInsets.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: AppBorders.lg,
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                      SizedBox(width: AppSpacing.sm.w),
                      Text(
                        "NAI's Daily Briefing",
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  briefingAsync.when(
                    data: (briefing) => Text(
                      briefing.content,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                    loading: () => Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => Text(
                      "Couldn't load today's briefing.",
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.lg.h),
            Text(
              'Latest Headlines',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm.h),

            latestNewsAsync.when(
              data: (articles) => Column(
                children: articles.map((article) {
                  return Card(
                    margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
                    child: ListTile(
                      title: Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        article.source,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }).toList(),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Text(
                "Couldn't load headlines.",
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
