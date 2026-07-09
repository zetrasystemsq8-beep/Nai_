import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/features/nigeria/presentation/providers/news_provider.dart';

import '../../data/daily_briefing_service.dart';
import '../../domain/daily_briefing.dart';

final dailyBriefingServiceProvider = Provider<DailyBriefingService>((ref) {
  return DailyBriefingService(newsRepository: ref.watch(newsRepositoryProvider));
});

final dailyBriefingProvider = FutureProvider<DailyBriefing>((ref) async {
  final service = ref.watch(dailyBriefingServiceProvider);
  return service.getTodaysBriefing();
});
