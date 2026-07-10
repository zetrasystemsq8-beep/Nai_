import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/challenge_generator.dart';
import '../../data/coin_wallet_store.dart';
import '../../data/game_progress_store.dart';

final challengeGeneratorProvider = Provider((ref) => ChallengeGenerator());
final coinWalletProvider = Provider((ref) => CoinWalletStore());
final gameProgressProvider = Provider((ref) => GameProgressStore());
