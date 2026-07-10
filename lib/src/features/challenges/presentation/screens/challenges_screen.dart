import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import '../../domain/challenge.dart';
import '../providers/challenge_provider.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
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

  @override
  void initState() {
    super.initState();
    _refreshWalletInfo();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _refreshWalletInfo() async {
    final wallet = ref.read(coinWalletProvider);
    final balance = await wallet.getBalance();
    final streak = await wallet.getStreak();
    final count = await wallet.getTodaysChallengeCount();
    final cost = await wallet.getNextChallengeCost();
    if (mounted) {
      setState(() {
        _balance = balance;
        _streak = streak;
        _todayCount = count;
        _nextCost = cost;
      });
    }
  }

  Future<void> _startChallenge() async {
    final wallet = ref.read(coinWalletProvider);
    final canStart = await wallet.canStartChallenge();

    if (!canStart) {
      if (mounted) {
        showGlobalToast(
          message: 'Not enough coins for another challenge today',
          status: 'error',
        );
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
    await wallet.recordChallengeStart();
    await _refreshWalletInfo();

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
    final isCorrect = await generator.checkAnswer(challenge, _answerController.text);

    if (isCorrect) {
      await wallet.recordWin(challenge.difficulty.coinReward);
      await _refreshWalletInfo();
    }

    setState(() {
      _checking = false;
      _wasCorrect = isCorrect;
      _resultMessage = isCorrect
          ? "Correct! You earned ${challenge.difficulty.coinReward} coins."
          : "Not quite. The answer was: ${challenge.correctAnswer}";
    });
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet summary card
            Container(
              padding: EdgeInsets.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: AppBorders.lg,
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _WalletStat(label: 'Coins', value: '$_balance', textTheme: textTheme, colorScheme: colorScheme),
                  _WalletStat(label: 'Streak', value: '$_streak 🔥', textTheme: textTheme, colorScheme: colorScheme),
                  _WalletStat(
                    label: 'Today',
                    value: '$_todayCount/3 free',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
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
                        _nextCost > 0
                            ? 'Next challenge costs $_nextCost coins'
                            : "You've got free challenges today!",
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
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    Text(
                      _currentChallenge!.question,
                      style: textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
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
                    color: (_wasCorrect ?? false)
                        ? Colors.green.withValues(alpha: 0.1)
                        : colorScheme.error.withValues(alpha: 0.1),
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
      ),
    );
  }
}

class _WalletStat extends StatelessWidget {
  const _WalletStat({
    required this.label,
    required this.value,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
        Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
