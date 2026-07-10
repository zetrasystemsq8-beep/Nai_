import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

import '../domain/challenge.dart';

class ChallengeGenerator {
  final Dio _dio = Dio();
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  ChallengeDifficulty _pickDifficulty() {
    final roll = Random().nextInt(100);
    if (roll < 45) return ChallengeDifficulty.easy;
    if (roll < 75) return ChallengeDifficulty.medium;
    if (roll < 95) return ChallengeDifficulty.hard;
    return ChallengeDifficulty.expert;
  }

  Future<Challenge> generate() async {
    final difficulty = _pickDifficulty();
    final category = challengeCategories[Random().nextInt(challengeCategories.length)];

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
            {
              'role': 'system',
              'content': '''
Generate one ${difficulty.label} difficulty "$category" challenge question for a Nigerian app. Respond ONLY with valid JSON, no markdown, no preamble, in this exact format:
{"question": "the question text", "answer": "the exact correct short answer"}
The answer must be short (a word, number, or short phrase) so it can be matched against user input. Do not include the answer inside the question text.
''',
            },
            {'role': 'user', 'content': 'Generate the challenge now.'},
          ],
          'temperature': 0.9,
          'max_tokens': 300,
        },
      );

      final content = response.data['choices']?[0]?['message']?['content'] as String?;
      final parsed = jsonDecode(content ?? '{}') as Map<String, dynamic>;

      return Challenge(
        id: const Uuid().v4(),
        category: category,
        difficulty: difficulty,
        question: parsed['question'] as String? ?? 'Could not generate a question. Try again.',
        correctAnswer: (parsed['answer'] as String? ?? '').trim(),
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      return Challenge(
        id: const Uuid().v4(),
        category: category,
        difficulty: difficulty,
        question: isOffline
            ? "You're offline — connect to the internet to get a challenge."
            : 'Could not generate a challenge right now. Please try again.',
        correctAnswer: '',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return Challenge(
        id: const Uuid().v4(),
        category: category,
        difficulty: difficulty,
        question: 'Could not generate a challenge right now. Please try again.',
        correctAnswer: '',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<bool> checkAnswer(Challenge challenge, String userAnswer) async {
    if (challenge.correctAnswer.isEmpty) return false;

    final normalizedCorrect = challenge.correctAnswer.trim().toLowerCase();
    final normalizedUser = userAnswer.trim().toLowerCase();
    if (normalizedCorrect == normalizedUser) return true;

    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You judge quiz answers. Given the correct answer and a user\'s answer, respond ONLY with "true" if the user\'s answer is correct (allowing for typos, case differences, or equivalent phrasing) or "false" if it is not. No other text.',
            },
            {
              'role': 'user',
              'content':
                  'Correct answer: "${challenge.correctAnswer}"\nUser answer: "$userAnswer"\nIs the user correct?',
            },
          ],
          'temperature': 0.0,
          'max_tokens': 10,
        },
      );

      final content = (response.data['choices']?[0]?['message']?['content'] as String? ?? '').trim().toLowerCase();
      return content.contains('true');
    } catch (e) {
      return false;
    }
  }
}
