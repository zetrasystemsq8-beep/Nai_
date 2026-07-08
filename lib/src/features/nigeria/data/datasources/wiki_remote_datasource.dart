import 'package:nai/src/config/app_config.dart';
import '../models/wiki_entry_model.dart';

abstract class WikiRemoteDataSource {
  Future<List<WikiEntryModel>> searchWiki({
    required String query,
    required int page,
    required int pageSize,
  });

  Future<List<WikiEntryModel>> getEntriesByCategory({
    required String category,
    required int page,
    required int pageSize,
  });

  Future<List<WikiEntryModel>> getFeaturedEntries({
    required int limit,
  });

  Future<WikiEntryModel> getEntryDetails(String entryId);

  Future<List<WikiEntryModel>> getRelatedEntries({
    required String entryId,
    required int limit,
  });

  Future<List<String>> getWikiCategories();
}

class WikiRemoteDataSourceImpl implements WikiRemoteDataSource {
  WikiRemoteDataSourceImpl();

  @override
  Future<List<WikiEntryModel>> searchWiki({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/wiki/search',
        queryParameters: {
          'q': query,
          'page': page,
          'pageSize': pageSize,
        },
      );

      final entries = (response.data['data'] as List?)
              ?.map((e) => WikiEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return entries;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<WikiEntryModel>> getEntriesByCategory({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/wiki/category/$category',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final entries = (response.data['data'] as List?)
              ?.map((e) => WikiEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return entries;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<WikiEntryModel>> getFeaturedEntries({
    required int limit,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/wiki/featured',
        queryParameters: {'limit': limit},
      );

      final entries = (response.data['data'] as List?)
              ?.map((e) => WikiEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return entries;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WikiEntryModel> getEntryDetails(String entryId) async {
    try {
      final response = await AppConfig.dio.get(
        '/wiki/entries/$entryId',
      );

      final entry =
          WikiEntryModel.fromJson(response.data['data'] as Map<String, dynamic>);
      return entry;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<WikiEntryModel>> getRelatedEntries({
    required String entryId,
    required int limit,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/wiki/entries/$entryId/related',
        queryParameters: {'limit': limit},
      );

      final entries = (response.data['data'] as List?)
              ?.map((e) => WikiEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return entries;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getWikiCategories() async {
    try {
      final response = await AppConfig.dio.get(
        '/wiki/categories',
      );

      final categories = List<String>.from(
          response.data['data'] as List? ?? []);
      return categories;
    } catch (e) {
      rethrow;
    }
  }
}
