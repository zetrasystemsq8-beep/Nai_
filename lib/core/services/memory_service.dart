import 'package:hive_ce/hive_ce.dart';

class MemoryService {
  static final MemoryService _instance = MemoryService._internal();
  factory MemoryService() => _instance;
  MemoryService._internal();

  late Box _chatBox;
  static const String _chatBoxName = 'chat_memory';

  Future<void> init() async {
    _chatBox = await Hive.openBox(_chatBoxName);
  }

  Future<void> saveMessage({
    required String role,
    required String content,
    required DateTime timestamp,
  }) async {
    final key = '${role}_${timestamp.millisecondsSinceEpoch}';
    await _chatBox.put(key, {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final messages = <Map<String, dynamic>>[];
    for (var key in _chatBox.keys) {
      final data = _chatBox.get(key) as Map<String, dynamic>;
      messages.add(data);
    }
    messages.sort((a, b) {
      final aTime = DateTime.parse(a['timestamp'] as String);
      final bTime = DateTime.parse(b['timestamp'] as String);
      return aTime.compareTo(bTime);
    });
    return messages;
  }

  Future<void> clearChat() async {
    await _chatBox.clear();
  }

  Future<void> deleteMessage(String key) async {
    await _chatBox.delete(key);
  }

  Future<int> getMessageCount() async {
    return _chatBox.length;
  }

  Future<void> deleteAllMessages() async {
    await _chatBox.clear();
  }
}
