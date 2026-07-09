import 'package:nai/src/utils/utils.dart';
import 'package:nai/src/features/nigeria/domain/repositories/news_repository.dart';
import 'package:nai/src/features/nigeria/domain/entities/news_article.dart';

import '../domain/ai_engine.dart';
import '../domain/news_intent_router.dart';

/// Concrete [AIEngine] that answers purely from the News API, with no LLM
/// involved. Formats matching articles into a readable response.
///
/// This is a placeholder knowledge layer — a future custom-built AI engine
/// can implement [AIEngine] directly and replace this without any changes
/// to the chat UI.
class NewsAIEngine implements AIEngine {
  final NewsRepository _newsRepository;
  final NewsIntentRouter _router;

  NewsAIEngine({
    required NewsRepository newsRepository,
    NewsIntentRouter router = const NewsIntentRouter(),
  })  : _newsRepository = newsRepository,
        _router = router;

  @override
  Future<String> respond(String userQuery) async {
    if (userQuery.trim().isEmpty) {
      return "Please ask me something about Nigeria — news, events, or topics you're curious about.";
    }

    if (!_router.shouldRouteToNews(userQuery)) {
      return "I'm not sure how to help with that yet.";
    }

    final searchQuery = _router.extractSearchQuery(userQuery);

    final result = await _newsRepository.searchNews(
      query: searchQuery,
      page: 1,
      pageSize: 5,
    );

    return result.fold(
      (failure) => "I couldn't fetch news right now (${failure.message}). Please try again shortly.",
      (articles) => _formatResponse(searchQuery, articles),
    );
  }

  String _formatResponse(String query, List<NewsArticle> articles) {
    if (articles.isEmpty) {
      return "I couldn't find any recent news about \"$query\". Try asking about a different topic.";
    }

    final buffer = StringBuffer();
    buffer.writeln("Here's what I found about \"$query\":\n");

    for (var i = 0; i < articles.length; i++) {
      final article = articles[i];
      buffer.writeln('${i + 1}. ${article.title}');
      if (article.description.isNotEmpty) {
        buffer.writeln('   ${article.description}');
      }
      buffer.writeln('   Source: ${article.source}');
      if (i < articles.length - 1) buffer.writeln();
    }

    return buffer.toString().trim();
  }
}
