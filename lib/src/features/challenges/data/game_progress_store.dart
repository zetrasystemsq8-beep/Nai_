import 'dart:math';
import 'package:hive_ce/hive.dart';

import '../domain/achievement.dart';

/// Handles XP/levels, daily missions, achievements, daily login rewards,
/// and lucky spin — all local, on-device progress tracking.
class GameProgressStore {
  static const _boxName = 'game_progress';

  Box? _box;

  Future<Box> _getBox() async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // ===== XP & LEVELS =====

  Future<int> getXp() async {
    final box = await _getBox();
    return box.get('xp', defaultValue: 0) as int;
  }

  Future<int> addXp(int amount) async {
    final box = await _getBox();
    final current = box.get('xp', defaultValue: 0) as int;
    final newXp = current + amount;
    await box.put('xp', newXp);
    return newXp;
  }

  /// Level formula: each level needs progressively more XP
  /// (level N requires N*100 total XP to reach).
  int levelForXp(int xp) {
    int level = 1;
    int required = 0;
    while (true) {
      required += level * 100;
      if (xp < required) break;
      level++;
      if (level > 100) return 100;
    }
    return level;
  }

  int xpNeededForNextLevel(int xp) {
    final level = levelForXp(xp);
    int required = 0;
    for (var i = 1; i <= level; i++) {
      required += i * 100;
    }
    return required - xp;
  }

  // ===== DAILY MISSIONS =====

  Future<Map<String, int>> _getTodayMissionProgress() async {
    final box = await _getBox();
    final raw = box.get('missions_$_todayKey') as Map?;
    if (raw == null) {
      return {'completed': 0, 'wins': 0, 'questions': 0, 'minutes': 0};
    }
    return raw.map((k, v) => MapEntry(k as String, v as int));
  }

  Future<void> _saveTodayMissionProgress(Map<String, int> progress) async {
    final box = await _getBox();
    await box.put('missions_$_todayKey', progress);
  }

  Future<void> recordChallengeCompleted({required bool won}) async {
    final progress = await _getTodayMissionProgress();
    progress['completed'] = (progress['completed'] ?? 0) + 1;
    if (won) progress['wins'] = (progress['wins'] ?? 0) + 1;
    await _saveTodayMissionProgress(progress);
    await _checkMissionClaims();
  }

  Future<void> recordQuestionAsked() async {
    final progress = await _getTodayMissionProgress();
    progress['questions'] = (progress['questions'] ?? 0) + 1;
    await _saveTodayMissionProgress(progress);
    await _checkMissionClaims();
  }

  Future<Set<String>> _getClaimedMissions() async {
    final box = await _getBox();
    final raw = box.get('claimed_$_todayKey') as List?;
    return raw?.cast<String>().toSet() ?? {};
  }

  Future<int> _checkMissionClaims() async {
    // Auto-claims missions the moment their condition is met; returns
    // total coins newly awarded this call (0 if nothing new).
    final progress = await _getTodayMissionProgress();
    final claimed = await _getClaimedMissions();
    final box = await _getBox();
    int awarded = 0;

    final missionChecks = <String, bool>{
      'complete_3': (progress['completed'] ?? 0) >= 3,
      'win_2': (progress['wins'] ?? 0) >= 2,
      'ask_5': (progress['questions'] ?? 0) >= 5,
    };

    final rewards = {'complete_3': 20, 'win_2': 15, 'ask_5': 5};

    for (final entry in missionChecks.entries) {
      if (entry.value && !claimed.contains(entry.key)) {
        claimed.add(entry.key);
        awarded += rewards[entry.key] ?? 0;
      }
    }

    if (awarded > 0) {
      await box.put('claimed_$_todayKey', claimed.toList());
      final currentCoins = box.get('mission_coins', defaultValue: 0) as int;
      await box.put('mission_coins', currentCoins + awarded);
    }

    return awarded;
  }

  Future<List<MissionStatus>> getTodayMissions() async {
    final progress = await _getTodayMissionProgress();
    final claimed = await _getClaimedMissions();

    return [
      MissionStatus(
        id: 'complete_3',
        title: 'Complete 3 challenges',
        reward: 20,
        current: (progress['completed'] ?? 0).clamp(0, 3),
        target: 3,
        claimed: claimed.contains('complete_3'),
      ),
      MissionStatus(
        id: 'win_2',
        title: 'Win 2 challenges',
        reward: 15,
        current: (progress['wins'] ?? 0).clamp(0, 2),
        target: 2,
        claimed: claimed.contains('win_2'),
      ),
      MissionStatus(
        id: 'ask_5',
        title: 'Ask NAI 5 questions',
        reward: 5,
        current: (progress['questions'] ?? 0).clamp(0, 5),
        target: 5,
        claimed: claimed.contains('ask_5'),
      ),
    ];
  }

  /// Coins earned from missions today, to be added to the main wallet
  /// balance by the caller.
  Future<int> collectMissionCoins() async {
    final box = await _getBox();
    final coins = box.get('mission_coins', defaultValue: 0) as int;
    await box.put('mission_coins', 0);
    return coins;
  }

  // ===== DAILY LOGIN REWARD =====

  Future<LoginRewardResult> checkDailyLogin() async {
    final box = await _getBox();
    final lastLoginDate = box.get('last_login_date') as String?;
    final loginStreak = box.get('login_streak', defaultValue: 0) as int;

    if (lastLoginDate == _todayKey) {
      return LoginRewardResult(alreadyClaimedToday: true, streakDay: loginStreak, coinsAwarded: 0);
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

    int newStreak;
    if (lastLoginDate == yesterdayKey) {
      newStreak = loginStreak + 1;
      if (newStreak > 7) newStreak = 1; // cycle resets after day 7
    } else {
      newStreak = 1;
    }

    final rewardTable = {1: 5, 2: 10, 3: 15, 4: 20, 5: 30, 6: 50, 7: 100};
    final coins = rewardTable[newStreak] ?? 5;

    await box.put('last_login_date', _todayKey);
    await box.put('login_streak', newStreak);

    return LoginRewardResult(alreadyClaimedToday: false, streakDay: newStreak, coinsAwarded: coins);
  }

  // ===== LUCKY SPIN =====

  Future<bool> canSpinToday() async {
    final box = await _getBox();
    final lastSpinDate = box.get('last_spin_date') as String?;
    return lastSpinDate != _todayKey;
  }

  Future<SpinResult> spin() async {
    final box = await _getBox();
    final outcomes = [
      SpinResult(SpinResultType.coins, 5),
      SpinResult(SpinResultType.coins, 10),
      SpinResult(SpinResultType.coins, 20),
      SpinResult(SpinResultType.freeChallenge, 0),
      SpinResult(SpinResultType.doubleReward, 0),
    ];
    final result = outcomes[Random().nextInt(outcomes.length)];
    await box.put('last_spin_date', _todayKey);
    if (result.type == SpinResultType.freeChallenge) {
      final freeSpins = box.get('bonus_free_challenges', defaultValue: 0) as int;
      await box.put('bonus_free_challenges', freeSpins + 1);
    }
    if (result.type == SpinResultType.doubleReward) {
      await box.put('double_reward_active', true);
    }
    return result;
  }

  Future<bool> consumeDoubleRewardIfActive() async {
    final box = await _getBox();
    final active = box.get('double_reward_active', defaultValue: false) as bool;
    if (active) await box.put('double_reward_active', false);
    return active;
  }

  Future<int> getBonusFreeChallenges() async {
    final box = await _getBox();
    return box.get('bonus_free_challenges', defaultValue: 0) as int;
  }

  Future<void> consumeBonusFreeChallenge() async {
    final box = await _getBox();
    final current = box.get('bonus_free_challenges', defaultValue: 0) as int;
    if (current > 0) await box.put('bonus_free_challenges', current - 1);
  }

  // ===== ACHIEVEMENTS =====

  Future<void> recordWinForAchievements(String category) async {
    final box = await _getBox();
    final totalWins = (box.get('total_wins', defaultValue: 0) as int) + 1;
    final totalCompleted = (box.get('total_completed', defaultValue: 0) as int) + 1;
    await box.put('total_wins', totalWins);
    await box.put('total_completed', totalCompleted);

    final winsByCategoryRaw = box.get('wins_by_category') as Map? ?? {};
    final winsByCategory = winsByCategoryRaw.map((k, v) => MapEntry(k as String, v as int));
    winsByCategory[category] = (winsByCategory[category] ?? 0) + 1;
    await box.put('wins_by_category', winsByCategory);
  }

  Future<void> recordCompletionForAchievements() async {
    final box = await _getBox();
    final totalCompleted = (box.get('total_completed', defaultValue: 0) as int) + 1;
    await box.put('total_completed', totalCompleted);
  }

  Future<AchievementStats> getAchievementStats() async {
    final box = await _getBox();
    final totalWins = box.get('total_wins', defaultValue: 0) as int;
    final totalCompleted = box.get('total_completed', defaultValue: 0) as int;
    final bestStreak = box.get('best_streak', defaultValue: 0) as int;
    final winsByCategoryRaw = box.get('wins_by_category') as Map? ?? {};
    final winsByCategory = winsByCategoryRaw.map((k, v) => MapEntry(k as String, v as int));

    return AchievementStats(
      totalWins: totalWins,
      totalCompleted: totalCompleted,
      bestStreak: bestStreak,
      winsByCategory: winsByCategory,
    );
  }

  Future<void> updateBestStreak(int currentStreak) async {
    final box = await _getBox();
    final best = box.get('best_streak', defaultValue: 0) as int;
    if (currentStreak > best) await box.put('best_streak', currentStreak);
  }
}

class MissionStatus {
  final String id;
  final String title;
  final int reward;
  final int current;
  final int target;
  final bool claimed;

  const MissionStatus({
    required this.id,
    required this.title,
    required this.reward,
    required this.current,
    required this.target,
    required this.claimed,
  });

  bool get isComplete => current >= target;
}

class LoginRewardResult {
  final bool alreadyClaimedToday;
  final int streakDay;
  final int coinsAwarded;

  const LoginRewardResult({
    required this.alreadyClaimedToday,
    required this.streakDay,
    required this.coinsAwarded,
  });
}

enum SpinResultType { coins, freeChallenge, doubleReward }

class SpinResult {
  final SpinResultType type;
  final int coinAmount;

  const SpinResult(this.type, this.coinAmount);

  String get label {
    switch (type) {
      case SpinResultType.coins:
        return '+$coinAmount Coins';
      case SpinResultType.freeChallenge:
        return 'Free Extra Challenge';
      case SpinResultType.doubleReward:
        return 'Double Reward (next challenge)';
    }
  }
}
