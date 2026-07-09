import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import 'package:nai/src/features/nigeria/presentation/providers/news_provider.dart';
import 'package:nai/src/features/nigeria/presentation/providers/wiki_provider.dart';
import 'package:nai/src/features/nigeria/presentation/screens/wiki_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  Timer? _debounce;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _activeQuery = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final hasQuery = _activeQuery.isNotEmpty;

    final newsResults = hasQuery ? ref.watch(searchNewsProvider(_activeQuery)) : null;
    final wikiResults = hasQuery ? ref.watch(searchWikiProvider(_activeQuery)) : null;

    return Scaffold(
      appBar: const AppTopBar(title: 'Search'),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search news, wiki, and more...',
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
                onChanged: _onChanged,
              ),
            ),
            Expanded(
              child: !hasQuery
                  ? Center(
                      child: AppEmptyState(
                        title: 'Start Searching',
                        subtitle: 'Search news, wiki entries, and more',
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
                      children: [
                        Text(
                          'News',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: AppSpacing.sm.h),
                        newsResults!.when(
                          data: (articles) => articles.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: AppSpacing.md.h),
                                  child: Text(
                                    'No news results',
                                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                )
                              : Column(
                                  children: articles.take(5).map((a) {
                                    return Card(
                                      margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
                                      child: ListTile(
                                        title: Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                                        subtitle: Text(a.source),
                                      ),
                                    );
                                  }).toList(),
                                ),
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, __) => Text(
                            'Could not load news results',
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg.h),
                        Text(
                          'Wikipedia',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: AppSpacing.sm.h),
                        wikiResults!.when(
                          data: (entries) => entries.isEmpty
                              ? Text(
                                  'No wiki results',
                                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                )
                              : Column(
                                  children: entries.take(5).map((entry) {
                                    return Card(
                                      margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
                                      child: ListTile(
                                        title: Text(entry.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                                        subtitle: Text(
                                          entry.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => WikiDetailScreen(entry: entry),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, __) => Text(
                            'Could not load wiki results',
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl.h),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
