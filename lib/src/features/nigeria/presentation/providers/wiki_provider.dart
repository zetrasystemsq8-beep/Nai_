import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/wiki_remote_datasource.dart';
import '../../data/repositories/wiki_repository_impl.dart';
import '../../domain/entities/wiki_entry.dart';
import '../../domain/repositories/wiki_repository.dart';

final wikiRemoteDataSourceProvider = Provider<WikiRemoteDataSource>((ref) {
  return WikiRemoteDataSourceImpl();
});

final wikiRepositoryProvider = Provider<WikiRepository>((ref) {
  return WikiRepositoryImpl(
    ref.watch(wikiRemoteDataSourceProvider),
  );
});

final featuredWikiProvider = FutureProvider<List<WikiEntry>>((ref) async {
  final repository = ref.watch(wikiRepositoryProvider);
  final result = await repository.getFeaturedEntries(limit: 10);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (entries) => entries,
  );
});

final searchWikiProvider = FutureProvider.family<List<WikiEntry>, String>(
  (ref, query) async {
    final repository = ref.watch(wikiRepositoryProvider);
    final result = await repository.searchWiki(
      query: query,
      page: 1,
      pageSize: 20,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (entries) => entries,
    );
  },
);

final wikiEntriesByCategoryProvider =
    FutureProvider.family<List<WikiEntry>, String>(
  (ref, category) async {
    final repository = ref.watch(wikiRepositoryProvider);
    final result = await repository.getEntriesByCategory(
      category: category,
      page: 1,
      pageSize: 20,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (entries) => entries,
    );
  },
);

final wikiCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(wikiRepositoryProvider);
  final result = await repository.getWikiCategories();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});
