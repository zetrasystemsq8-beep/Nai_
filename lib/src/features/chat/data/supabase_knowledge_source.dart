import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseKnowledgeSource {
  Future<String?> search(String query) async {
    try {
      final response = await Supabase.instance.client
          .from('nigeria_knowledge')
          .select('source_name, category, content')
          .textSearch('search_vector', query, config: 'english')
          .limit(3);

      if (response.isEmpty) return null;

      final buffer = StringBuffer();
      for (final row in response) {
        buffer.writeln('- [${row['source_name']}] (${row['category']}): ${row['content']}');
      }
      return buffer.toString().trim();
    } catch (e) {
      return null;
    }
  }
}
