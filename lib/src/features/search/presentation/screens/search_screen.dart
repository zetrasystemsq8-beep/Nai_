import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  bool _isSearching = false;

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

    return Scaffold(
      appBar: const AppTopBar(title: 'Search'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search chats, news, services...',
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
              ),
            ),
            Expanded(
              child: _searchController.text.isEmpty
                  ? Center(
                      child: Text(
                        'Enter a search query',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : const Center(
                      child: AppLoading(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
