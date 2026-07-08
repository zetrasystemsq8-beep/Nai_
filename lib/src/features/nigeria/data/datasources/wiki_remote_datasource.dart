import 'package:dio/dio.dart';
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
  final Dio _dio = Dio();

  @override
  Future<List<WikiEntryModel>> searchWiki({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.get(
        'https://en.wikipedia.org/w/api.php',
        queryParameters: {
          'action': 'query',
          'list': 'search',
          'srsearch': query,
          'format': 'json',
          'srlimit': pageSize,
          'sroffset': (page - 1) * pageSize,
          'utf8': '1',
        },
      );

      final searchResults = response.data['query']['search'] as List? ?? [];

      return searchResults.map((e) {
        return WikiEntryModel(
          id: e['pageid']?.toString() ?? '',
          title: e['title'] ?? 'Untitled',
          description: (e['snippet'] as String? ?? '').replaceAll(RegExp(r'<[^>]*>'), ''),
          content: '',
          keywords: const [],
          imageUrl: '',
          lastUpdated: DateTime.now(),
          category: '',
        );
      }).toList();
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
    // Uses the same Wikipedia search API with category as query
    return await searchWiki(
      query: category,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<WikiEntryModel>> getFeaturedEntries({
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        'https://en.wikipedia.org/w/api.php',
        queryParameters: {
          'action': 'query',
          'list': 'random',
          'rnlimit': limit,
          'format': 'json',
          'utf8': '1',
        },
      );

      final results = response.data['query']['random'] as List? ?? [];

      return results.map((e) {
        return WikiEntryModel(
          id: e['id']?.toString() ?? '',
          title: e['title'] ?? 'Untitled',
          description: 'Wikipedia article',
          content: '',
          keywords: const [],
          imageUrl: '',
          lastUpdated: DateTime.now(),
          category: '',
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WikiEntryModel> getEntryDetails(String entryId) async {
    try {
      final response = await _dio.get(
        'https://en.wikipedia.org/w/api.php',
        queryParameters: {
          'action': 'query',
          'pageids': entryId,
          'prop': 'extracts|info',
          'exintro': 'true',
          'explaintext': 'true',
          'format': 'json',
          'utf8': '1',
        },
      );

      final pages = response.data['query']['pages'] as Map<String, dynamic>;
      final page = pages[entryId] as Map<String, dynamic>;

      final extract = page['extract'] as String? ?? 'No description available.';

      return WikiEntryModel(
        id: entryId,
        title: page['title'] ?? 'Untitled',
        description: extract.length > 200 ? '${extract.substring(0, 200)}...' : extract,
        content: extract,
        keywords: const [],
        imageUrl: '',
        lastUpdated: DateTime.now(),
        category: '',
      );
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
      // First get the page title
      final detailResponse = await _dio.get(
        'https://en.wikipedia.org/w/api.php',
        queryParameters: {
          'action': 'query',
          'pageids': entryId,
          'prop': 'info',
          'format': 'json',
          'utf8': '1',
        },
      );

      final pages = detailResponse.data['query']['pages'] as Map<String, dynamic>;
      final page = pages[entryId] as Map<String, dynamic>;
      final title = page['title'] ?? '';

      // Search for related articles
      return await searchWiki(
        query: title,
        page: 1,
        pageSize: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getWikiCategories() async {
    try {
      final response = await _dio.get(
        'https://en.wikipedia.org/w/api.php',
        queryParameters: {
          'action': 'query',
          'list': 'allcategories',
          'aclimit': 20,
          'format': 'json',
          'utf8': '1',
        },
      );

      final categories = response.data['query']['allcategories'] as List? ?? [];

      return categories.map((e) => e['*'] as String? ?? '').toList();
    } catch (e) {
      rethrow;
    }
  }
}
