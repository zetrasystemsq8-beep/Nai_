import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/features/nigeria/presentation/providers/news_provider.dart';
import 'package:nai/src/features/nigeria/presentation/providers/wiki_provider.dart';

import '../../domain/ai_engine.dart';
import '../../data/grounded_ai_engine.dart';

final aiEngineProvider = Provider<AIEngine>((ref) {
  return GroundedAIEngine(
    newsRepository: ref.watch(newsRepositoryProvider),
    wikiRepository: ref.watch(wikiRepositoryProvider),
  );
});
