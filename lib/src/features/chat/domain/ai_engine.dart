abstract class AIEngine {
  /// Takes a raw user question and returns a natural-language style answer.
  /// [history] is recent conversation turns (role: 'user'/'assistant',
  /// content: message text) so the engine can understand context-dependent
  /// follow-ups like "ok" or "why" instead of treating every message as
  /// isolated.
  Future<String> respond(String userQuery, {List<Map<String, String>> history});
}
