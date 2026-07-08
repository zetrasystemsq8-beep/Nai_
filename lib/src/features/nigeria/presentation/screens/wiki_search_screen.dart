import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import '../providers/wiki_provider.dart';
import '../widgets/wiki_result_card.dart';

class WikiSearchScreen extends ConsumerStatefulWidget {
  const WikiSearchScreen({super.key});

  @override
  ConsumerState<WikiSearchScreen> createState() => _WikiSearchScreenState();
}

class _WikiSearchScreenState extends ConsumerState<WikiSearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final hasSearchQuery = _searchController.text.isNotEmpty;
    final wikiResults = hasSearchQuery
        ? ref.watch(searchWikiProvider(_searchController.text))
        : null;

    return Scaffold(
      appBar: const AppTopBar(title: 'Wiki Search'),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Nigeria Wiki...',
                  prefixIcon: const Icon(IconsaxPlusLinear.search_normal),
                  border: OutlineInputBorder(
                    borderRadius: AppBorders.card,
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md.w,
                    vertical: AppSpacing.sm.h,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (hasSearchQuery)
              Expanded(
                child: wikiResults!.when(
                  data: (entries) => entries.isEmpty
                      ? Center(
                          child: AppEmptyState(
                            title: 'No Results Found',
                            subtitle: 'Try a different search query',
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(AppSpacing.md.w),
                          itemCount: entries.length,
                          itemBuilder: (context, index) => WikiResultCard(
                            entry: entries[index],
                            onTap: () {
                              showGlobalToast(
                                message: 'Wiki entry selected',
                                status: 'success',
                              );
                            },
                          ),
                        ),
                  loading: () => const Center(child: AppLoading()),
                  error: (error, stack) => Center(
                    child: AppErrorWidget(
                      title: 'Error loading wiki',
                      message: error.toString(),
                      onRetry: () =>
                          ref.refresh(searchWikiProvider(_searchController.text)),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    'Start typing to search',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
