import 'package:nai/src/utils/utils.dart';
import '../../domain/entities/wiki_entry.dart';
import '../../domain/repositories/wiki_repository.dart';
import '../datasources/wiki_remote_datasource.dart';

class WikiRepositoryImpl implements WikiRepository {
  final WikiRemoteDataSource _remoteDataSource;

  WikiRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<List<WikiEntry>> searchWiki({
    required String query,
    required int page,
    required int pageSize,
  }) {
    return runTask(() => _remoteDataSource.searchWiki(
      query: query,
      page: page,
      pageSize: pageSize,
    ));
  }

  @override
  FutureEither<List<WikiEntry>> getEntriesByCategory({
    required String category,
    required int page,
    required int pageSize,
  }) {
    return runTask(() => _remoteDataSource.getEntriesByCategory(
      category: category,
      page: page,
      pageSize: pageSize,
    ));
  }

  @override
  FutureEither<List<WikiEntry>> getFeaturedEntries({
    required int limit,
  }) {
    return runTask(() => _remoteDataSource.getFeaturedEntries(limit: limit));
  }

  @override
  FutureEither<WikiEntry> getEntryDetails(String entryId) {
    return runTask(() => _remoteDataSource.getEntryDetails(entryId));
  }

  @override
  FutureEither<List<WikiEntry>> getRelatedEntries({
    required String entryId,
    required int limit,
  }) {
    return runTask(() => _remoteDataSource.getRelatedEntries(
      entryId: entryId,
      limit: limit,
    ));
  }

  @override
  FutureEither<List<String>> getWikiCategories() {
    return runTask(() => _remoteDataSource.getWikiCategories());
  }
}
