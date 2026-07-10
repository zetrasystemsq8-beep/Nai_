class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool Function(AchievementStats stats) isUnlocked;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });
}

class AchievementStats {
  final int totalWins;
  final int totalCompleted;
  final int bestStreak;
  final Map<String, int> winsByCategory;

  const AchievementStats({
    required this.totalWins,
    required this.totalCompleted,
    required this.bestStreak,
    required this.winsByCategory,
  });
}

final List<Achievement> allAchievements = [
  Achievement(
    id: 'first_win',
    emoji: '🥉',
    title: 'First Win',
    description: 'Win your first challenge',
    isUnlocked: (stats) => stats.totalWins >= 1,
  ),
  Achievement(
    id: 'hundred_completed',
    emoji: '🥈',
    title: '100 Challenges Completed',
    description: 'Complete 100 challenges',
    isUnlocked: (stats) => stats.totalCompleted >= 100,
  ),
  Achievement(
    id: 'thirty_day_streak',
    emoji: '🥇',
    title: '30-Day Streak',
    description: 'Keep a 30-day winning streak',
    isUnlocked: (stats) => stats.bestStreak >= 30,
  ),
  Achievement(
    id: 'nigeria_expert',
    emoji: '🇳🇬',
    title: 'Nigeria Expert',
    description: 'Win 10 Nigeria category challenges',
    isUnlocked: (stats) => (stats.winsByCategory['Nigeria'] ?? 0) >= 10,
  ),
  Achievement(
    id: 'programming_master',
    emoji: '💻',
    title: 'Programming Master',
    description: 'Win 10 Programming category challenges',
    isUnlocked: (stats) => (stats.winsByCategory['Programming'] ?? 0) >= 10,
  ),
  Achievement(
    id: 'ai_genius',
    emoji: '🤖',
    title: 'AI Genius',
    description: 'Win 10 AI category challenges',
    isUnlocked: (stats) => (stats.winsByCategory['AI'] ?? 0) >= 10,
  ),
];
