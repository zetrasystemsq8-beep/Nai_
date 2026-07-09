import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:nai/src/features/nigeria/domain/repositories/news_repository.dart';
import 'package:nai/src/features/nigeria/domain/repositories/wiki_repository.dart';

import '../domain/ai_engine.dart';

/// Grounded AI engine: pulls real facts from News + Wikipedia, then hands
/// them to Groq to write a natural, conversational answer. Falls back to
/// a plain Groq call (no grounding) for general/non-factual questions
/// like small talk, coding help, or advice — since those don't need
/// external facts.
class GroundedAIEngine implements AIEngine {
  final NewsRepository _newsRepository;
  final WikiRepository _wikiRepository;
  final Dio _dio = Dio();

  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.1-8b-instant';

  GroundedAIEngine({
    required NewsRepository newsRepository,
    required WikiRepository wikiRepository,
  })  : _newsRepository = newsRepository,
        _wikiRepository = wikiRepository;

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static const _systemPrompt = '''
You are NAI — Nigeria's AI Assistant.

You are a helpful, general-purpose assistant: you can answer general knowledge questions, help with coding, explain concepts, hold normal conversation, and assist with everyday tasks.

The one strict rule: you do not answer questions that are specifically scoped to a country, market, or context OTHER than Nigeria. For example:
- "How do I start programming?" -> Answer normally, this is general knowledge.
- "How do I get a client in the USA?" -> Decline, this is scoped to a non-Nigerian market.
- "Who is the best footballer?" -> Answer with a Nigerian player (e.g. Victor Osimhen, Ademola Lookman), not a non-Nigerian player.
- "Explain how neural networks work" -> Answer normally, universal knowledge.

When declining, be brief and friendly, then offer a Nigeria-focused version of the same question if relevant.

When you are given "Reference material" below, use it as your source of truth and write a natural, conversational summary in your own words — do not just repeat it verbatim, and do not mention that you were given reference material. If the reference material doesn't actually answer the question, say so honestly rather than guessing.

Keep responses concise and conversational.
''';

  @override
  Future<String> respond(String userQuery) async {
    if (userQuery.trim().isEmpty) {
      return "Ask me anything — I'm here to help, especially with anything Nigeria-related.";
    }

    final reference = await _gatherReference(userQuery);
    return _askGroq(userQuery, reference);
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
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
        data: {
          'model': _model,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': userContent},
          ],
          'temperature': 0.7,
          'max_tokens': 800,
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
