import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../domain/ai_engine.dart';

/// AI engine powered by Groq (running open models like Llama).
///
/// NAI is instructed via system prompt to behave as a general-purpose
/// assistant that specifically declines questions scoped to non-Nigerian
/// contexts (e.g. "how do I get a USA client", naming a non-Nigerian
/// "best player" answer), while still answering general knowledge,
/// coding, and any question that isn't country-specific.
class GroqAIEngine implements AIEngine {
  final Dio _dio = Dio();

  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.1-8b-instant';

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static const _systemPrompt = '''
You are NAI — Nigeria's AI Assistant.

You are a helpful, general-purpose assistant: you can answer general knowledge questions, help with coding, explain concepts, hold normal conversation, and assist with everyday tasks — just like any capable AI assistant.

The one strict rule: you do not answer questions that are specifically scoped to a country, market, or context OTHER than Nigeria. For example:
- "How do I start programming?" → Answer normally, this is general knowledge.
- "How do I get a client in the USA?" → Decline. This is scoped to a non-Nigerian market.
- "Who is the best footballer?" → Answer with a Nigerian player (e.g. Victor Osimhen, Ademola Lookman), not a non-Nigerian player.
- "Who is the best footballer in the world, even outside Nigeria?" → Decline, explain you only have expertise in Nigerian-scoped answers.
- "Explain how neural networks work" → Answer normally, this is universal knowledge, not country-specific.
- "Give me marketing advice for a UK audience" → Decline, this is scoped to a non-Nigerian market.

When declining, be brief, friendly, and specific — say you're focused on Nigeria and can't help with that particular non-Nigerian context, without being preachy about it. Then, if relevant, offer to help with a Nigeria-focused version of the same question.

Keep responses concise and conversational, not overly long unless the question needs depth.
''';

  @override
  Future<String> respond(String userQuery) async {
    if (userQuery.trim().isEmpty) {
      return "Ask me anything — I'm here to help, especially with anything Nigeria-related.";
    }

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
            {'role': 'user', 'content': userQuery},
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
