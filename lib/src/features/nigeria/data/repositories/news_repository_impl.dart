import 'package:nai/src/utils/utils.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource _remoteDataSource;

  NewsRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<List<NewsArticle>> getLatestNews({
    required int page,
    required int pageSize,
    String? category,
  }) {
    return runTask(() => _remoteDataSource.getLatestNews(
      page: page,
      pageSize: pageSize,
      category: category,
    ));
  }

  @override
  FutureEither<List<NewsArticle>> searchNews({
    required String query,
    required int page,
    required int pageSize,
  }) {
    return runTask(() => _remoteDataSource.searchNews(
      query: query,
      page: page,
      pageSize: pageSize,
    ));
  }

  @override
  FutureEither<List<NewsArticle>> getNewsByCategory({
    required String category,
    required int page,
    required int pageSize,
  }) {
    return runTask(() => _remoteDataSource.getNewsByCategory(
      category: category,
      page: page,
      pageSize: pageSize,
    ));
  }

  @override
  FutureEither<List<NewsArticle>> getTrendingNews({
    required int limit,
  }) {
    return runTask(() => _remoteDataSource.getTrendingNews(limit: limit));
  }

  @override
  FutureEither<void> bookmarkArticle(String articleId) {
    return runTask(() async {
      // TODO: Implement local storage for bookmarks
      return;
    });
  }

  @override
  FutureEither<List<NewsArticle>> getBookmarkedArticles() {
    return runTask(() async {
      // TODO: Implement local storage retrieval for bookmarks
      return [];
    });
  }

  @override
  FutureEither<void> removeBookmark(String articleId) {
    return runTask(() async {
      // TODO: Implement local storage removal for bookmarks
      return;
    });
  }
}
