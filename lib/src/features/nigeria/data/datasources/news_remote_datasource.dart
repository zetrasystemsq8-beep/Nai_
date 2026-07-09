import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news_article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsArticleModel>> getLatestNews({
    required int page,
    required int pageSize,
    String? category,
  });

  Future<List<NewsArticleModel>> searchNews({
    required String query,
    required int page,
    required int pageSize,
  });

  Future<List<NewsArticleModel>> getNewsByCategory({
    required String category,
    required int page,
    required int pageSize,
  });

  Future<List<NewsArticleModel>> getTrendingNews({
    required int limit,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio _dio = Dio();

  static const _baseUrl = 'https://newsapi.org/v2';

  // Nigerian-focused sources available on NewsAPI's source list.
  static const _nigerianSources =
      'the-guardian-nigeria,premium-times-nigeria,punch-newspapers,vanguard-news';

  String get _apiKey => dotenv.env['NEWS_API_KEY'] ?? '';

  NewsArticleModel _mapArticle(Map<String, dynamic> json, {String category = ''}) {
    final url = json['url'] as String? ?? '';
    return NewsArticleModel(
      id: url.isNotEmpty ? url.hashCode.toString() : DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      content: json['content'] as String? ?? json['description'] as String? ?? '',
      source: (json['source'] as Map<String, dynamic>?)?['name'] as String? ?? 'Unknown',
      imageUrl: json['urlToImage'] as String? ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      category: category,
    );
  }

  @override
  Future<List<NewsArticleModel>> getLatestNews({
    required int page,
    required int pageSize,
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/top-headlines',
        queryParameters: {
          'sources': _nigerianSources,
          'page': page,
          'pageSize': pageSize,
          'apiKey': _apiKey,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      final articles = (response.data['articles'] as List?) ?? [];
      return articles
          .map((e) => _mapArticle(e as Map<String, dynamic>, category: category ?? ''))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<NewsArticleModel>> searchNews({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/everything',
        queryParameters: {
          'q': query,
          'domains': 'guardian.ng,premiumtimesng.com,punchng.com,vanguardngr.com',
          'page': page,
          'pageSize': pageSize,
          'sortBy': 'publishedAt',
          'apiKey': _apiKey,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      final articles = (response.data['articles'] as List?) ?? [];
      return articles.map((e) => _mapArticle(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<NewsArticleModel>> getNewsByCategory({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    // NewsAPI's category filter isn't compatible with specific `sources`,
    // so we search Nigerian domains scoped by category keyword instead.
    try {
      final response = await _dio.get(
        '$_baseUrl/everything',
        queryParameters: {
          'q': category,
          'domains': 'guardian.ng,premiumtimesng.com,punchng.com,vanguardngr.com',
          'page': page,
          'pageSize': pageSize,
          'sortBy': 'publishedAt',
          'apiKey': _apiKey,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      final articles = (response.data['articles'] as List?) ?? [];
      return articles
          .map((e) => _mapArticle(e as Map<String, dynamic>, category: category))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<NewsArticleModel>> getTrendingNews({
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/top-headlines',
        queryParameters: {
          'sources': _nigerianSources,
          'pageSize': limit,
          'apiKey': _apiKey,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      final articles = (response.data['articles'] as List?) ?? [];
      return articles.map((e) => _mapArticle(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }
}
