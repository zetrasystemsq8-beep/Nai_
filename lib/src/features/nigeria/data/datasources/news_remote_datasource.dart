import 'package:dio/dio.dart';
import 'package:nai/src/config/app_config.dart';
import '../models/news_article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsArticleModel>> getLatestNews({
    required int page,
    required int pageSize,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  @override
  Future<List<NewsArticleModel>> getLatestNews({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/news/latest',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
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
      rethrow;
    }
  }
}
