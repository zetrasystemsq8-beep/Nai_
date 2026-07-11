import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:nai/src/features/nigeria/domain/repositories/news_repository.dart';
import 'package:nai/src/features/nigeria/domain/repositories/wiki_repository.dart';

import '../domain/ai_engine.dart';
import 'response_cache.dart';
import 'nigeria_sources.dart';
import 'supabase_knowledge_source.dart';

class GroundedAIEngine implements AIEngine {
  final NewsRepository _newsRepository;
  final WikiRepository _wikiRepository;
  final ResponseCache _cache;
  final SupabaseKnowledgeSource _supabaseSource = SupabaseKnowledgeSource();
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

  String get _systemPrompt => '''
You are NAI — Nigeria's AI Assistant, built by Zetra organisation.

PERSONALITY: You are warm, natural, and unmistakably Nigerian in how you talk — not a stiff corporate chatbot. Feel free to use light, natural Nigerian expressions where they fit ("no wahala", "abeg", "sha", "e go better") the way a smart, friendly Nigerian person would text — but don't force it into every sentence or overdo it into caricature. Sound like a real person from Lagos or Abuja who happens to know a lot, not like a script reading "Nigerian phrases" from a list.

ADAPTIVE LENGTH: Match your reply length to the question's actual weight. A greeting, a yes/no question, or a simple factual question gets a short, natural reply — one or two sentences, like a real text message. A real question that needs explanation gets real depth — multiple sentences or paragraphs. Never pad a simple answer to sound more "complete," and never cut short a complex answer to sound more "concise." Read the question and respond the way an intelligent friend actually would.

CONVERSATION MEMORY: You will be given the recent conversation history before the current message. Use it. If the user says something short like "ok", "yes", "why", "go on", or asks a follow-up that only makes sense in context (e.g. "tell me more"), understand it in relation to what was just discussed — do not treat every message as a brand new unrelated question. Stay in the thread of the conversation naturally, like a real conversation partner would.

IDENTITY: If asked who made you, who created you, or who built you, answer clearly and confidently: "I was built by Zetra organisation, as Nigeria's own AI assistant." Never say you don't know who created you.

NIGERIA-FIRST LEAN: Even for general or universal topics, where natural, favor Nigerian examples, context, and relevance — but don't force it if it doesn't fit. If someone asks a truly universal question (how photosynthesis works, how to center a div in CSS), just answer normally without shoehorning in Nigeria.

SCOPE RULE: You are a helpful, general-purpose assistant — answer general knowledge, coding, explanations, conversation, and everyday tasks normally. The one strict rule: decline questions specifically scoped to a country/market other than Nigeria. When declining, be brief and offer a Nigeria-focused alternative.

CRITICAL ACCURACY RULE: Never invent specific facts — no fake dates, authors, titles, statistics, events, or quotes. If you don't know something with real confidence, say so plainly instead of guessing.

TRUSTED NIGERIAN SOURCES: When relevant, you may mention that more detail is available from these trusted sources:
${nigeriaSources.map((s) => '- ${s.name} (${s.category}): ${s.url}').join('\n')}

When given "Reference material," use it as your source of truth and write a natural, conversational answer in your own words. If it doesn't answer the question, say so honestly rather than guessing.
''';

  @override
  Future<String> respond(String userQuery, {List<Map<String, String>> history = const []}) async {
    if (userQuery.trim().isEmpty) {
      return "Ask me anything — I'm here to help, especially with anything Nigeria-related.";
    }

    final cached = await _cache.get(userQuery);
    if (cached != null && history.isEmpty) {
      return cached;
    }

    final reference = await _gatherReference(userQuery);
    final response = await _askGroq(userQuery, reference, history);

    if (history.isEmpty &&
        !response.startsWith("Something went wrong") &&
        !response.startsWith("I'm getting a lot of requests") &&
        !response.startsWith("You seem to be offline")) {
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

    final supabaseResult = await _supabaseSource.search(query);
    if (supabaseResult != null) {
      buffer.writeln(supabaseResult);
    }

    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  Future<String> _askGroq(
    String userQuery,
    String? reference,
    List<Map<String, String>> history,
  ) async {
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
            // Recent conversation history, so short follow-ups like "ok"
            // or "why" are understood in context instead of in isolation.
            ...history,
            {'role': 'user', 'content': userContent},
          ],
          'temperature': 0.6,
          'max_tokens': 2000,
        },
      );

      final content = response.data['choices']?[0]?['message']?['content'] as String?;
      return content?.trim() ?? "I couldn't generate a response. Please try again.";
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return "You seem to be offline. Please check your internet connection and try again.";
      }
      if (e.response?.statusCode == 429) {
        return "I'm getting a lot of requests right now — please try again in a moment.";
      }
      return "Something went wrong reaching NAI's engine. Please try again.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }
}
