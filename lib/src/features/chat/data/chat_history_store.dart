import 'package:hive_ce/hive.dart';
import '../domain/chat_message.dart';

/// Persists chat sessions locally on-device using Hive.
class ChatHistoryStore {
  static const _boxName = 'chat_sessions';

  Box? _box;

  Future<Box> _getBox() async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  Future<List<ChatSession>> getAllSessions() async {
    final box = await _getBox();
    final sessions = box.values
        .map((e) => ChatSession.fromJson(e as Map))
        .toList();
    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sessions;
  }

  Future<void> saveSession(ChatSession session) async {
    final box = await _getBox();
    await box.put(session.id, session.toJson());
  }

  Future<void> deleteSession(String sessionId) async {
    final box = await _getBox();
    await box.delete(sessionId);
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    final box = await _getBox();
    final raw = box.get(sessionId) as Map?;
    if (raw == null) return;
    final session = ChatSession.fromJson(raw);
    final renamed = ChatSession(
      id: session.id,
      title: newTitle,
      createdAt: session.createdAt,
      messages: session.messages,
    );
    await box.put(sessionId, renamed.toJson());
  }

  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
