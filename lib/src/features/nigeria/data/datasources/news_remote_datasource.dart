import 'package:dio/dio.dart';
import 'package:nai/src/config/app_config.dart';
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
  @override
  Future<List<NewsArticleModel>> getLatestNews({
    required int page,
    required int pageSize,
    String? category,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/news/latest',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (category != null) 'category': category,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final articles = (response.data['data'] as List?)
              ?.map((e) => NewsArticleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      return articles;
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
    // TODO: Real NewsAPI (Guardian Nigeria, Punch, Premium Times) integration pending.
    return [];
  }

  @override
  Future<List<NewsArticleModel>> getNewsByCategory({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    // TODO: Real NewsAPI integration pending.
    return [];
  }

  @override
  Future<List<NewsArticleModel>> getTrendingNews({
    required int limit,
  }) async {
    // TODO: Real NewsAPI integration pending.
    return [];
  }
}
