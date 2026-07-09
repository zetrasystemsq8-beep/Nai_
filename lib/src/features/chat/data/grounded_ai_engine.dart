import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:nai/src/features/nigeria/domain/repositories/news_repository.dart';
import 'package:nai/src/features/nigeria/domain/repositories/wiki_repository.dart';

import '../domain/ai_engine.dart';
import 'response_cache.dart';

class GroundedAIEngine implements AIEngine {
  final NewsRepository _newsRepository;
  final WikiRepository _wikiRepository;
  final ResponseCache _cache;
  final Dio _dio = Dio();

  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  GroundedAIEngine({
    required NewsRepository newsRepository,
    required WikiRepository wikiRepository,
    ResponseCache? cache,
  })  : _newsRepository = newsRepository,
        _wikiRepository = wikiRepository,
        _cache = cache ?? ResponseCache();

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static const _systemPrompt = '''
You are NAI — Nigeria's AI Assistant, built by Zetra organisation.

IDENTITY: If asked who made you, who created you, or who built you, answer clearly and confidently: "I was built by Zetra organisation, as Nigeria's own AI assistant." Never say you don't know who created you.

DEPTH: Give thorough, detailed, well-explained answers — like a knowledgeable expert taking the question seriously, not a search engine giving a one-line snippet. Use multiple sentences or paragraphs when a topic deserves it. Match the depth of the question: a simple greeting gets a short reply, a real question gets a real, complete answer.

SCOPE RULE: You are a helpful, general-purpose assistant — answer general knowledge, coding, explanations, conversation, and everyday tasks normally. The one strict rule: decline questions specifically scoped to a country/market other than Nigeria. When declining, be brief and offer a Nigeria-focused alternative. Universal topics are NOT country-scoped — always answer those normally.

CRITICAL ACCURACY RULE: You must NEVER invent specific facts — no fake dates, no fake authors, no fake song/article/book titles, no fake statistics, no fake events, no fake quotes. If you do not know something with real confidence, say plainly "I don't have reliable information on that" instead of generating a plausible-sounding but made-up answer. A confident wrong answer is much worse than an honest "I don't know." This applies especially to insults, jokes, or unusual phrases directed at you — do not invent a fake "meaning" or fake "origin" for a phrase; just respond naturally as yourself.

FOCUS: Stay directly on topic. Do not pivot to unrelated suggestions unless asked.

When given "Reference material," use it as your source of truth and write a natural, conversational answer in your own words. If the reference material doesn't answer the question, say so honestly rather than guessing.
''';

  @override
  Future<String> respond(String userQuery) async {
    if (userQuery.trim().isEmpty) {
      return "Ask me anything — I'm here to help, especially with anything Nigeria-related.";
    }

    final cached = await _cache.get(userQuery);
    if (cached != null) {
      return cached;
    }

    final reference = await _gatherReference(userQuery);
    final response = await _askGroq(userQuery, reference);

    if (!response.startsWith("Something went wrong") &&
        !response.startsWith("I'm getting a lot of requests")) {
      await _cache.set(userQuery, response);
    }

    return response;
  }

  Future<String?> _gatherReference(String query) async {
    final buffer = StringBuffer();

    final newsResult = await _newsRepository.searchNews(query: query, page: 1, pageSize: 3);
    newsResult.fold((_) {}, (articles) {
      for (final a in articles) {
        buffer.writeln('- [News] ${a.title}: ${a.description}');
      }
    });

    final wikiResult = await _wikiRepository.searchWiki(query: query, page: 1, pageSize: 2);
    wikiResult.fold((_) {}, (entries) {
      for (final e in entries) {
        buffer.writeln('- [Wikipedia] ${e.title}: ${e.description}');
      }
    });

    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  Future<String> _askGroq(String userQuery, String? reference) async {
    final userContent = reference != null
        ? 'Reference material:\n$reference\n\nUser question: $userQuery'
        : userQuery;

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
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': userContent},
          ],
          'temperature': 0.3,
          'max_tokens': 2000,
        },
      );

      final content = response.data['choices']?[0]?['message']?['content'] as String?;
      return content?.trim() ?? "I couldn't generate a response. Please try again.";
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return "I'm getting a lot of requests right now — please try again in a moment.";
      }
      return "Something went wrong reaching NAI's engine. Please try again.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }
}
