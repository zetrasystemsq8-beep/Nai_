import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/challenge_generator.dart';
import '../../data/coin_wallet_store.dart';

final challengeGeneratorProvider = Provider((ref) => ChallengeGenerator());
final coinWalletProvider = Provider((ref) => CoinWalletStore());
