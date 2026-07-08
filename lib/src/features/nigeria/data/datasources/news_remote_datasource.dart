import 'package:dio/dio.dart';
import 'package:nai/src/config/app_config.dart';
import 'package:nai/src/utils/utils.dart';
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
  NewsRemoteDataSourceImpl();

  @override
  Future<List<NewsArticleModel>> getLatestNews({
    required int page,
    required int pageSize,
    String? category,
  }) async {
    try {
      final params = {
        'page': page,
        'pageSize': pageSize,
        if (category != null) 'category': category,
      };

      final response = await AppConfig.dio.get(
        '/news/latest',
        queryParameters: params,
      );

      final articles = (response.data['data'] as List?)
              ?.map((e) => NewsArticleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return articles;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<NewsArticleModel>> searchNews({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/news/search',
        queryParameters: {
          'q': query,
          'page': page,
          'pageSize': pageSize,
        },
      );

      final articles = (response.data['data'] as List?)
              ?.map((e) => NewsArticleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return articles;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<NewsArticleModel>> getNewsByCategory({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/news/category/$category',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final articles = (response.data['data'] as List?)
              ?.map((e) => NewsArticleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return articles;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<NewsArticleModel>> getTrendingNews({
    required int limit,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/news/trending',
        queryParameters: {'limit': limit},
      );

      final articles = (response.data['data'] as List?)
              ?.map((e) => NewsArticleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return articles;
    } catch (e) {
      rethrow;
    }
  }
}
