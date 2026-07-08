import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';

class NigeriaNewsScreen extends ConsumerWidget {
  const NigeriaNewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestNews = ref.watch(latestNewsProvider);
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Scaffold(
      appBar: const AppTopBar(title: 'Nigeria News'),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: latestNews.when(
          data: (articles) => articles.isEmpty
              ? Center(
                  child: AppEmptyState(
                    title: 'No News Available',
                    subtitle: 'Check back later for updates',
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.md.w),
                  itemCount: articles.length,
                  itemBuilder: (context, index) => NewsCard(
                    article: articles[index],
                    onTap: () {
                      showGlobalToast(
                        message: 'Opened from news feed',
                        status: 'success',
                      );
                    },
                  ),
                ),
          loading: () => const Center(child: AppLoading()),
          error: (error, stack) => Center(
            child: AppErrorWidget(
              title: 'Error loading news',
              message: error.toString(),
              onRetry: () => ref.refresh(latestNewsProvider),
            ),
          ),
        ),
      ),
    );
  }
}
