import 'package:nai/src/utils/utils.dart';
import '../../domain/entities/government_service.dart';
import '../../domain/repositories/government_repository.dart';
import '../datasources/government_remote_datasource.dart';

class GovernmentRepositoryImpl implements GovernmentRepository {
  final GovernmentRemoteDataSource _remoteDataSource;

  GovernmentRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<List<GovernmentService>> getAllServices({
    required int page,
    required int pageSize,
  }) {
    return runTask(() => _remoteDataSource.getAllServices(
      page: page,
      pageSize: pageSize,
    ));
  }

  @override
  FutureEither<List<GovernmentService>> searchServices({
    required String query,
    required int page,
    required int pageSize,
  }) {
    return runTask(() => _remoteDataSource.searchServices(
      query: query,
      page: page,
      pageSize: pageSize,
    ));
  }

  @override
  FutureEither<List<GovernmentService>> getServicesByCategory({
    required String category,
    required int page,
    required int pageSize,
  }) {
    return runTask(() => _remoteDataSource.getServicesByCategory(
      category: category,
      page: page,
      pageSize: pageSize,
    ));
  }

  @override
  FutureEither<List<GovernmentService>> getPopularServices({
    required int limit,
  }) {
    return runTask(() => _remoteDataSource.getPopularServices(limit: limit));
  }

  @override
  FutureEither<GovernmentService> getServiceDetails(String serviceId) {
    return runTask(() => _remoteDataSource.getServiceDetails(serviceId));
  }

  @override
  FutureEither<List<String>> getCategories() {
    return runTask(() => _remoteDataSource.getCategories());
  }
}
