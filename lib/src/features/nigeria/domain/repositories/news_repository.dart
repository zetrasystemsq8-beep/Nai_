import 'package:nai/src/utils/utils.dart';
import '../entities/news_article.dart';

abstract class NewsRepository {
  /// Fetch latest Nigerian news articles
  FutureEither<List<NewsArticle>> getLatestNews({
    required int page,
    required int pageSize,
    String? category,
  });

  /// Search news by query
  FutureEither<List<NewsArticle>> searchNews({
    required String query,
    required int page,
    required int pageSize,
  });

  /// Get news articles by category
  FutureEither<List<NewsArticle>> getNewsByCategory({
    required String category,
    required int page,
    required int pageSize,
  });

  /// Get trending news
  FutureEither<List<NewsArticle>> getTrendingNews({
    required int limit,
  });

  /// Bookmark a news article
  FutureEither<void> bookmarkArticle(String articleId);

  /// Get bookmarked articles
  FutureEither<List<NewsArticle>> getBookmarkedArticles();

  /// Remove bookmark from article
  FutureEither<void> removeBookmark(String articleId);
}
