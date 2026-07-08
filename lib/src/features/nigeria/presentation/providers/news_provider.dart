import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/news_remote_datasource.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  return NewsRemoteDataSourceImpl();
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    ref.watch(newsRemoteDataSourceProvider),
  );
});

final latestNewsProvider =
    FutureProvider<List<NewsArticle>>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  final result = await repository.getLatestNews(
    page: 1,
    pageSize: 20,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (articles) => articles,
  );
});

final trendingNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  final result = await repository.getTrendingNews(limit: 10);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (articles) => articles,
  );
});

final searchNewsProvider = FutureProvider.family<List<NewsArticle>, String>(
  (ref, query) async {
    final repository = ref.watch(newsRepositoryProvider);
    final result = await repository.searchNews(
      query: query,
      page: 1,
      pageSize: 20,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (articles) => articles,
    );
  },
);

final newsByCategoryProvider =
    FutureProvider.family<List<NewsArticle>, String>(
  (ref, category) async {
    final repository = ref.watch(newsRepositoryProvider);
    final result = await repository.getNewsByCategory(
      category: category,
      page: 1,
      pageSize: 20,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (articles) => articles,
    );
  },
);
