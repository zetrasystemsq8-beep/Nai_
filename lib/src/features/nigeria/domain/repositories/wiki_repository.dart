import 'package:nai/src/utils/utils.dart';
import '../entities/wiki_entry.dart';

abstract class WikiRepository {
  /// Search wiki entries
  FutureEither<List<WikiEntry>> searchWiki({
    required String query,
    required int page,
    required int pageSize,
  });

  /// Get wiki entries by category
  FutureEither<List<WikiEntry>> getEntriesByCategory({
    required String category,
    required int page,
    required int pageSize,
  });

  /// Get featured wiki entries
  FutureEither<List<WikiEntry>> getFeaturedEntries({
    required int limit,
  });

  /// Get wiki entry details
  FutureEither<WikiEntry> getEntryDetails(String entryId);

  /// Get related wiki entries
  FutureEither<List<WikiEntry>> getRelatedEntries({
    required String entryId,
    required int limit,
  });

  /// Get available wiki categories
  FutureEither<List<String>> getWikiCategories();
}
