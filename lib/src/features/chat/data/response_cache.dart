import 'package:hive_ce/hive.dart';

/// Caches AI responses by normalized question text, so repeat questions
/// across all users never re-hit the Groq API. Uses a 7-day expiry so
/// news-sensitive answers don't go stale forever.
class ResponseCache {
  static const _boxName = 'ai_response_cache';
  static const _maxAge = Duration(days: 7);

  Box? _box;

  Future<Box> _getBox() async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  String _normalize(String query) {
    return query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<String?> get(String query) async {
    final box = await _getBox();
    final key = _normalize(query);
    final entry = box.get(key) as Map?;
    if (entry == null) return null;

    final cachedAt = DateTime.tryParse(entry['cachedAt'] as String? ?? '');
    if (cachedAt == null || DateTime.now().difference(cachedAt) > _maxAge) {
      await box.delete(key);
      return null;
    }

    return entry['response'] as String?;
  }

  Future<void> set(String query, String response) async {
    final box = await _getBox();
    final key = _normalize(query);
    await box.put(key, {
      'response': response,
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }
}
