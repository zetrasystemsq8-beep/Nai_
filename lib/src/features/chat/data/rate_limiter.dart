import 'package:hive_ce/hive.dart';

/// Caps how many AI messages a single user can send per hour, protecting
/// the shared Groq quota from being drained by one heavy user while on
/// the free tier.
class RateLimiter {
  static const _boxName = 'rate_limiter';
  static const maxMessagesPerHour = 20;

  Box? _box;

  Future<Box> _getBox() async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  String get _hourKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}-${now.hour}';
  }

  Future<int> getMessagesSentThisHour() async {
    final box = await _getBox();
    return box.get(_hourKey, defaultValue: 0) as int;
  }

  Future<bool> canSendMessage() async {
    final count = await getMessagesSentThisHour();
    return count < maxMessagesPerHour;
  }

  Future<void> recordMessageSent() async {
    final box = await _getBox();
    final count = box.get(_hourKey, defaultValue: 0) as int;
    await box.put(_hourKey, count + 1);
  }

  Future<int> getMinutesUntilReset() async {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    return nextHour.difference(now).inMinutes;
  }
}
