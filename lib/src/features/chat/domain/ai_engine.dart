/// Abstract AI response engine.
///
/// This interface intentionally has zero dependency on any vendor SDK
/// (no Anthropic, OpenAI, Gemini, or otherwise). Today it is implemented
/// by [NewsAIEngine], which answers using only the News API as a knowledge
/// source. A custom-built AI engine can later implement this same interface
/// and be swapped in without touching any UI code.
abstract class AIEngine {
  /// Takes a raw user question and returns a natural-language style answer.
  Future<String> respond(String userQuery);
}
