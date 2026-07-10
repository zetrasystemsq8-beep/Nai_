import 'package:hive_ce/hive.dart';

/// Local coin ledger implementing the free/paid challenge economy.
/// NOTE: This is a local, on-device balance — not a tamper-proof server
/// ledger. Real money/ZTC conversion must NOT be built on top of this
/// without a backend-verified balance first.
class CoinWalletStore {
  static const _boxName = 'coin_wallet';
  static const _maxFreeChallengesPerDay = 3;

  Box? _box;

  Future<Box> _getBox() async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<int> getBalance() async {
    final box = await _getBox();
    return box.get('balance', defaultValue: 0) as int;
  }

  Future<void> _addCoins(int amount) async {
    final box = await _getBox();
    final current = box.get('balance', defaultValue: 0) as int;
    await box.put('balance', current + amount);
  }

  Future<void> _spendCoins(int amount) async {
    final box = await _getBox();
    final current = box.get('balance', defaultValue: 0) as int;
    await box.put('balance', (current - amount).clamp(0, 1 << 31));
  }

  Future<int> getTodaysChallengeCount() async {
    final box = await _getBox();
    return box.get('count_$_todayKey', defaultValue: 0) as int;
  }

  Future<void> _incrementTodaysCount() async {
    final box = await _getBox();
    final current = box.get('count_$_todayKey', defaultValue: 0) as int;
    await box.put('count_$_todayKey', current + 1);
  }

  /// Returns the coin cost to start the NEXT challenge (0 if still within
  /// the free daily allowance), per the escalating cost rule.
  Future<int> getNextChallengeCost() async {
    final count = await getTodaysChallengeCount();
    if (count < _maxFreeChallengesPerDay) return 0;
    final paidAttemptNumber = count - _maxFreeChallengesPerDay + 1; // 1st paid = 4th overall
    switch (paidAttemptNumber) {
      case 1:
        return 5;
      case 2:
        return 6;
      case 3:
        return 7;
      default:
        return 10;
    }
  }

  /// Call before generating a challenge. Returns false if the user can't
  /// afford it (insufficient balance for a paid attempt).
  Future<bool> canStartChallenge() async {
    final cost = await getNextChallengeCost();
    if (cost == 0) return true;
    final balance = await getBalance();
    return balance >= cost;
  }

  /// Deducts cost (if any) and increments today's count. Call this when
  /// the user actually starts a challenge.
  Future<void> recordChallengeStart() async {
    final cost = await getNextChallengeCost();
    if (cost > 0) await _spendCoins(cost);
    await _incrementTodaysCount();
  }

  Future<void> recordWin(int reward) async {
    await _addCoins(reward);
    await _updateStreak();
  }

  Future<void> _updateStreak() async {
    final box = await _getBox();
    final lastWinDate = box.get('last_win_date') as String?;
    final streak = box.get('streak', defaultValue: 0) as int;

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

    if (lastWinDate == _todayKey) {
      return; // already counted today
    } else if (lastWinDate == yesterdayKey) {
      final newStreak = streak + 1;
      await box.put('streak', newStreak);
      await box.put('last_win_date', _todayKey);
      if (newStreak >= 7) {
        await _addCoins(100);
        await box.put('streak', 0); // reset after bonus
      }
    } else {
      await box.put('streak', 1);
      await box.put('last_win_date', _todayKey);
    }
  }

  Future<int> getStreak() async {
    final box = await _getBox();
    return box.get('streak', defaultValue: 0) as int;
  }
}
