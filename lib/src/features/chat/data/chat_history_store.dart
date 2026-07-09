import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
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

  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
