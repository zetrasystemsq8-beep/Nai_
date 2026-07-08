import 'package:dio/dio.dart';
import '../models/wiki_entry_model.dart';

abstract class WikiRemoteDataSource {
  Future<List<WikiEntryModel>> searchWiki({
    required String query,
    required int page,
    required int pageSize,
  });
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
          snippet: e['snippet']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
          url: 'https://en.wikipedia.org/?curid=${e['pageid']}',
          category: 'Wikipedia',
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
