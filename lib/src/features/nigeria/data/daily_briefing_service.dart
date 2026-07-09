import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce/hive.dart';

import 'package:nai/src/features/nigeria/domain/news_repository.dart';
import '../domain/daily_briefing.dart';

/// Generates one AI-written briefing per day from today's top Nigerian
/// news, cached locally so it's only generated once per day (not once
/// per app open).
class DailyBriefingService {
  final NewsRepository _newsRepository;
  final Dio _dio = Dio();

  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';
  static const _boxName = 'daily_briefing';

  DailyBriefingService({required NewsRepository newsRepository})
      : _newsRepository = newsRepository;

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<DailyBriefing> getTodaysBriefing() async {
    final box = await Hive.openBox(_boxName);
    final cached = box.get(_todayKey) as Map?;
    if (cached != null) {
      return DailyBriefing.fromJson(cached);
    }

    final briefing = await _generate();
    await box.put(_todayKey, briefing.toJson());
    return briefing;
  }

  Future<DailyBriefing> _generate() async {
    final result = await _newsRepository.getLatestNews(page: 1, pageSize: 8);

    final articlesText = result.fold(
      (failure) => '',
      (articles) => articles
          .map((a) => '- ${a.title}: ${a.description}')
          .join('\n'),
    );

    if (articlesText.isEmpty) {
      return DailyBriefing(
        content: "I couldn't fetch today's news right now. Please check back shortly.",
        generatedAt: DateTime.now(),
      );
    }

    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 25),
          receiveTimeout: const Duration(seconds: 25),
        ),
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''
You are NAI, writing a short daily Nigeria news briefing — like a well-informed friend giving a 60-second rundown, not a list of headlines. Write 2-3 natural paragraphs covering the most important stories below, in your own words, connecting related stories where relevant. Do not just restate headlines one by one. Do not invent facts beyond what's given. Start directly with the briefing, no greeting or preamble.
''',
            },
            {
              'role': 'user',
              'content': "Today's top Nigerian news:\n$articlesText",
            },
          ],
          'temperature': 0.4,
          'max_tokens': 700,
        },
      );

      final content = response.data['choices']?[0]?['message']?['content'] as String?;
      return DailyBriefing(
        content: content?.trim() ?? "Couldn't generate today's briefing. Please try again.",
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      return DailyBriefing(
        content: "Couldn't generate today's briefing right now. Please try again.",
        generatedAt: DateTime.now(),
      );
    }
  }
}
