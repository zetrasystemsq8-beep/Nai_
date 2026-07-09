import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/features/nigeria/presentation/providers/news_provider.dart';

import '../../domain/ai_engine.dart';
import '../../data/news_ai_engine.dart';

final aiEngineProvider = Provider<AIEngine>((ref) {
  return NewsAIEngine(
    newsRepository: ref.watch(newsRepositoryProvider),
  );
});
