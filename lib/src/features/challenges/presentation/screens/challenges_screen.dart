import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import '../../domain/challenge.dart';
import '../../domain/achievement.dart';
import '../../data/game_progress_store.dart';
import '../providers/challenge_provider.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _answerController = TextEditingController();

  Challenge? _currentChallenge;
  bool _loading = false;
  bool _checking = false;
  String? _resultMessage;
  bool? _wasCorrect;

  int _balance = 0;
  int _streak = 0;
  int _todayCount = 0;
  int _nextCost = 0;
  int _xp = 0;
  int _level = 1;
  int _bonusFreeChallenges = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshAll();
    _checkDailyLogin();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _checkDailyLogin() async {
    final progress = ref.read(gameProgressProvider);
    final wallet = ref.read(coinWalletProvider);
    final result = await progress.checkDailyLogin();
    if (!result.alreadyClaimedToday && mounted) {
      await wallet.addCoins(result.coinsAwarded);
      await _refreshAll();
      showGlobalToast(
        message: 'Day ${result.streakDay} login bonus: +${result.coinsAwarded} coins!',
        status: 'success',
      );
    }
  }

  Future<void> _refreshAll() async {
    final wallet = ref.read(coinWalletProvider);
    final progress = ref.read(gameProgressProvider);

    final missionCoins = await progress.collectMissionCoins();
    if (missionCoins > 0) await wallet.addCoins(missionCoins);

    final balance = await wallet.getBalance();
    final streak = await wallet.getStreak();
    final count = await wallet.getTodaysChallengeCount();
    final bonusFree = await progress.getBonusFreeChallenges();
    final cost = await wallet.getNextChallengeCost(bonusFreeChallenges: bonusFree);
    final xp = await progress.getXp();

    if (mounted) {
      setState(() {
        _balance = balance;
        _streak = streak;
        _todayCount = count;
        _nextCost = cost;
        _bonusFreeChallenges = bonusFree;
        _xp = xp;
        _level = progress.levelForXp(xp);
      });
    }
  }

  Future<void> _startChallenge() async {
    final wallet = ref.read(coinWalletProvider);
    final progress = ref.read(gameProgressProvider);
    final canStart = await wallet.canStartChallenge(bonusFreeChallenges: _bonusFreeChallenges);

    if (!canStart) {
      if (mounted) {
        showGlobalToast(message: 'Not enough coins for another challenge today', status: 'error');
      }
      return;
    }

    setState(() {
      _loading = true;
      _resultMessage = null;
      _wasCorrect = null;
      _answerController.clear();
    });

    final generator = ref.read(challengeGeneratorProvider);
    final challenge = await generator.generate();

    final cost = await wallet.getNextChallengeCost(bonusFreeChallenges: _bonusFreeChallenges);
    await wallet.recordChallengeStart(bonusFreeChallenges: _bonusFreeChallenges);
    if (cost == 0 && _todayCount >= 3) {
      await progress.consumeBonusFreeChallenge();
    }

    await _refreshAll();

    setState(() {
      _currentChallenge = challenge;
      _loading = false;
    });
  }

  Future<void> _submitAnswer() async {
    final challenge = _currentChallenge;
    if (challenge == null || _answerController.text.trim().isEmpty || _checking) return;

    setState(() => _checking = true);

    final generator = ref.read(challengeGeneratorProvider);
    final wallet = ref.read(coinWalletProvider);
    final progress = ref.read(gameProgressProvider);
    final isCorrect = await generator.checkAnswer(challenge, _answerController.text);

    if (isCorrect) {
      final hasDouble = await progress.consumeDoubleRewardIfActive();
      final reward = hasDouble ? challenge.difficulty.coinReward * 2 : challenge.difficulty.coinReward;
      await wallet.recordWin(reward);
      await progress.addXp(challenge.difficulty.xpReward);
      await progress.recordWinForAchievements(challenge.category);

      final newStreak = await wallet.getStreak();
      await progress.updateBestStreak(newStreak);

      setState(() {
        _checking = false;
        _wasCorrect = true;
        _resultMessage = hasDouble
            ? "Correct! Double reward: +$reward coins! 🎉"
            : "Correct! You earned $reward coins.";
      });
    } else {
      await progress.recordCompletionForAchievements();
      setState(() {
        _checking = false;
        _wasCorrect = false;
        _resultMessage = "Not quite. The answer was: ${challenge.correctAnswer}";
      });
    }

    await progress.recordChallengeCompleted(won: isCorrect);
    await _refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Challenges', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Play'),
            Tab(text: 'Missions'),
            Tab(text: 'Achievements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlayTab(colorScheme, textTheme),
          _MissionsTab(onClaimed: _refreshAll),
          const _AchievementsTab(),
        ],
      ),
    );
  }

  Widget _buildPlayTab(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: AppBorders.lg,
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _WalletStat(label: 'Coins', value: '$_balance', textTheme: textTheme, colorScheme: colorScheme),
                    _WalletStat(label: 'Level', value: '$_level', textTheme: textTheme, colorScheme: colorScheme),
                    _WalletStat(label: 'Streak', value: '$_streak 🔥', textTheme: textTheme, colorScheme: colorScheme),
                    _WalletStat(
                      label: 'Today',
                      value: '$_todayCount/${3 + _bonusFreeChallenges} free',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm.h),
                _LuckySpinButton(onSpun: _refreshAll),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          if (_currentChallenge == null) ...[
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl.h),
                child: Column(
                  children: [
                    Icon(IconsaxPlusLinear.cup, size: 64.sp, color: colorScheme.primary),
                    SizedBox(height: AppSpacing.md.h),
                    Text(
                      _nextCost > 0 ? 'Next challenge costs $_nextCost coins' : "You've got free challenges today!",
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.lg.h),
                    AppButton(
                      label: _loading ? 'Generating...' : 'Start Challenge',
                      onPressed: _loading ? null : _startChallenge,
                      isLoading: _loading,
                      variant: ButtonVariant.primary,
                      isFullWidth: false,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: AppBorders.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(label: Text(_currentChallenge!.category)),
                      SizedBox(width: AppSpacing.sm.w),
                      Chip(
                        label: Text(_currentChallenge!.difficulty.label),
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                      ),
                      const Spacer(),
                      Text(
                        '+${_currentChallenge!.difficulty.coinReward} coins',
                        style: textTheme.labelMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  Text(_currentChallenge!.question, style: textTheme.bodyLarge?.copyWith(height: 1.5)),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            if (_resultMessage == null) ...[
              TextField(
                controller: _answerController,
                enabled: !_checking,
                decoration: InputDecoration(
                  hintText: 'Your answer...',
                  border: OutlineInputBorder(borderRadius: AppBorders.card),
                ),
                onSubmitted: (_) => _submitAnswer(),
              ),
              SizedBox(height: AppSpacing.md.h),
              AppButton(
                label: _checking ? 'Checking...' : 'Submit Answer',
                onPressed: _checking ? null : _submitAnswer,
                isLoading: _checking,
                isFullWidth: true,
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.md.w),
                decoration: BoxDecoration(
                  color: (_wasCorrect ?? false) ? Colors.green.withValues(alpha: 0.1) : colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: AppBorders.lg,
                ),
                child: Text(
                  _resultMessage!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: (_wasCorrect ?? false) ? Colors.green : colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              AppButton(
                label: 'New Challenge',
                onPressed: () => setState(() => _currentChallenge = null),
                isFullWidth: true,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _WalletStat extends StatelessWidget {
  const _WalletStat({required this.label, required this.value, required this.textTheme, required this.colorScheme});

  final String label;
  final String value;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
        Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _LuckySpinButton extends ConsumerStatefulWidget {
  const _LuckySpinButton({required this.onSpun});

  final Future<void> Function() onSpun;

  @override
  ConsumerState<_LuckySpinButton> createState() => _LuckySpinButtonState();
}

class _LuckySpinButtonState extends ConsumerState<_LuckySpinButton> {
  bool _canSpin = true;
  bool _spinning = false;

  @override
  void initState() {
    super.initState();
    _checkCanSpin();
  }

  Future<void> _checkCanSpin() async {
    final progress = ref.read(gameProgressProvider);
    final canSpin = await progress.canSpinToday();
    if (mounted) setState(() => _canSpin = canSpin);
  }

  Future<void> _spin() async {
    setState(() => _spinning = true);
    final progress = ref.read(gameProgressProvider);
    final wallet = ref.read(coinWalletProvider);
    final result = await progress.spin();

    if (result.type == SpinResultType.coins) {
      await wallet.addCoins(result.coinAmount);
    }

    setState(() {
      _spinning = false;
      _canSpin = false;
    });

    await widget.onSpun();

    if (mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('🎰 Lucky Spin!'),
          content: Text('You won: ${result.label}'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Nice!')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: (!_canSpin || _spinning) ? null : _spin,
        icon: const Icon(Icons.casino_outlined, size: 18),
        label: Text(_canSpin ? (_spinning ? 'Spinning...' : 'Lucky Spin (Free)') : 'Come back tomorrow'),
      ),
    );
  }
}

class _MissionsTab extends ConsumerStatefulWidget {
  const _MissionsTab({required this.onClaimed});

  final Future<void> Function() onClaimed;

  @override
  ConsumerState<_MissionsTab> createState() => _MissionsTabState();
}

class _MissionsTabState extends ConsumerState<_MissionsTab> {
  List<MissionStatus> _missions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progress = ref.read(gameProgressProvider);
    final missions = await progress.getTodayMissions();
    if (mounted) setState(() => _missions = missions);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        await _load();
        await widget.onClaimed();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md.w),
        itemCount: _missions.length,
        itemBuilder: (context, index) {
          final mission = _missions[index];
          return Card(
            margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
            child: ListTile(
              title: Text(mission.title, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: LinearProgressIndicator(
                value: mission.target == 0 ? 0 : mission.current / mission.target,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
              trailing: mission.isComplete
                  ? Icon(Icons.check_circle, color: colorScheme.primary)
                  : Text('${mission.current}/${mission.target}', style: textTheme.bodySmall),
            ),
          );
        },
      ),
    );
  }
}

class _AchievementsTab extends ConsumerStatefulWidget {
  const _AchievementsTab();

  @override
  ConsumerState<_AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends ConsumerState<_AchievementsTab> {
  AchievementStats? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progress = ref.read(gameProgressProvider);
    final stats = await progress.getAchievementStats();
    if (mounted) setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    if (_stats == null) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md.w),
      itemCount: allAchievements.length,
      itemBuilder: (context, index) {
        final achievement = allAchievements[index];
        final unlocked = achievement.isUnlocked(_stats!);

        return Card(
          margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
          child: ListTile(
            leading: Opacity(
              opacity: unlocked ? 1.0 : 0.3,
              child: Text(achievement.emoji, style: const TextStyle(fontSize: 28)),
            ),
            title: Text(
              achievement.title,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: unlocked ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
              ),
            ),
            subtitle: Text(achievement.description, style: textTheme.bodySmall),
            trailing: unlocked ? Icon(Icons.check_circle, color: colorScheme.primary) : null,
          ),
        );
      },
    );
  }
}
