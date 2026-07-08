import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/features/nigeria/data/datasources/wiki_remote_datasource.dart';
import 'package:nai/src/features/nigeria/data/datasources/news_remote_datasource.dart';
import 'package:nai/src/features/nigeria/data/datasources/government_remote_datasource.dart';

final aiResponseProvider = FutureProvider.family<String, String>((ref, query) async {
  final wikiDataSource = WikiRemoteDataSourceImpl();
  final newsDataSource = NewsRemoteDataSourceImpl();
  final governmentDataSource = GovernmentRemoteDataSourceImpl();

  try {
    final responses = <String>[];

    // Search Wikipedia
    try {
      final wikiResults = await wikiDataSource.searchWiki(
        query: query,
        page: 1,
        pageSize: 3,
      );
      if (wikiResults.isNotEmpty) {
        responses.add('Wikipedia:\n${wikiResults.map((e) => '• ${e.title}: ${e.snippet}').join('\n')}');
      }
    } catch (_) {}

    // Get latest news
    try {
      final newsResults = await newsDataSource.getLatestNews(
        page: 1,
        pageSize: 5,
      );
      if (newsResults.isNotEmpty) {
        responses.add('News:\n${newsResults.map((e) => '• ${e.title}').join('\n')}');
      }
    } catch (_) {}

    // Build response from real data
    if (responses.isEmpty) {
      return 'No information found. Please try a different question.';
    }

    return responses.join('\n\n');
    
  } catch (e) {
    return 'Unable to retrieve information. Please try again.';
  }
});
