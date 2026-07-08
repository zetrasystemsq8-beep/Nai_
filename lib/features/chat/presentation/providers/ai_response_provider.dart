import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/features/nigeria/data/datasources/wiki_remote_datasource.dart';
import 'package:nai/src/features/nigeria/data/datasources/news_remote_datasource.dart';
import 'package:nai/src/features/nigeria/data/datasources/government_remote_datasource.dart';
import 'package:nai/src/core/services/memory_service.dart';

final aiResponseProvider = FutureProvider.family<String, String>((ref, query) async {
  final wikiDataSource = WikiRemoteDataSourceImpl();
  final newsDataSource = NewsRemoteDataSourceImpl();
  final governmentDataSource = GovernmentRemoteDataSourceImpl();
  final memoryService = MemoryService();

  try {
    String response = '';

    // 1. Search Wikipedia
    try {
      final wikiResults = await wikiDataSource.searchWiki(
        query: query,
        page: 1,
        pageSize: 3,
      );

      if (wikiResults.isNotEmpty) {
        response += '📚 **What Wikipedia says:**\n\n';
        for (var entry in wikiResults) {
          response += '• **${entry.title}**\n';
          response += '  ${entry.snippet}\n\n';
        }
      }
    } catch (_) {
      // Wikipedia search failed – continue
    }

    // 2. Get latest Nigerian news
    try {
      final newsResults = await newsDataSource.getLatestNews(
        page: 1,
        pageSize: 5,
      );

      if (newsResults.isNotEmpty) {
        response += '📰 **Latest Nigerian News:**\n\n';
        for (var article in newsResults.take(3)) {
          response += '• **${article.title}**\n';
          response += '  ${article.description}\n\n';
        }
      }
    } catch (_) {
      // News fetch failed – continue
    }

    // 3. Get government services (if relevant)
    if (_isGovernmentQuery(query)) {
      try {
        final services = await governmentDataSource.getAllServices(
          page: 1,
          pageSize: 3,
        );

        if (services.isNotEmpty) {
          response += '🏛️ **Government Services:**\n\n';
          for (var service in services.take(3)) {
            response += '• **${service.name}**\n';
            response += '  ${service.description}\n\n';
          }
        }
      } catch (_) {
        // Government services fetch failed – continue
      }
    }

    // 4. If no results found
    if (response.isEmpty) {
      response = 'I couldn\'t find specific information about "$query". Here are some things you can ask me:\n\n';
      response += '• Nigerian history and culture\n';
      response += '• Travel and tourism info\n';
      response += '• Current events and news\n';
      response += '• Government services\n';
      response += '• Nigerian food and traditions\n';
      response += '• Business and economy\n\n';
      response += 'Try asking more specific questions! 🇳🇬';
    }

    // 5. Save to memory (chat history)
    await memoryService.saveMessage(
      role: 'user',
      content: query,
      timestamp: DateTime.now(),
    );
    await memoryService.saveMessage(
      role: 'assistant',
      content: response,
      timestamp: DateTime.now().add(const Duration(seconds: 1)),
    );

    return response;
  } catch (e) {
    return 'I\'m having trouble retrieving information right now. Please try again later. 🇳🇬';
  }
});

bool _isGovernmentQuery(String query) {
  final keywords = ['government', 'service', 'nin', 'passport', 'tax', 'business registration', 'driver license', 'cac', 'firs', 'nimc'];
  final lower = query.toLowerCase();
  for (var keyword in keywords) {
    if (lower.contains(keyword)) return true;
  }
  return false;
}
