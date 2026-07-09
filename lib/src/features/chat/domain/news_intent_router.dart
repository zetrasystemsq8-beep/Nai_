/// Decides whether a user's question should be handled by the news
/// knowledge source. Currently News is the only knowledge source, so
/// every non-empty query routes there — this exists as a seam so future
/// sources (Wikipedia, Government services, etc.) can be added without
/// rewriting the engine.
class NewsIntentRouter {
  const NewsIntentRouter();

  bool shouldRouteToNews(String userQuery) {
    return userQuery.trim().isNotEmpty;
  }

  /// Extracts a clean search term from the raw user question.
  /// Strips common question words so the News API search is more likely
  /// to match relevant headlines.
  String extractSearchQuery(String userQuery) {
    final cleaned = userQuery
        .toLowerCase()
        .replaceAll(
          RegExp(
            r'\b(what|whats|is|are|the|tell|me|about|news|on|regarding|latest|update|updates)\b',
          ),
          '',
        )
        .replaceAll(RegExp(r'[?.!]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.isNotEmpty ? cleaned : userQuery.trim();
  }
}
