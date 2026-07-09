import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ai_engine.dart';
import '../../data/groq_ai_engine.dart';

final aiEngineProvider = Provider<AIEngine>((ref) {
  return GroqAIEngine();
});
