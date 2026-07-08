import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/government_remote_datasource.dart';
import '../../data/repositories/government_repository_impl.dart';
import '../../domain/entities/government_service.dart';
import '../../domain/repositories/government_repository.dart';

final governmentRemoteDataSourceProvider =
    Provider<GovernmentRemoteDataSource>((ref) {
  return GovernmentRemoteDataSourceImpl();
});

final governmentRepositoryProvider = Provider<GovernmentRepository>((ref) {
  return GovernmentRepositoryImpl(
    ref.watch(governmentRemoteDataSourceProvider),
  );
});

final allServicesProvider =
    FutureProvider<List<GovernmentService>>((ref) async {
  final repository = ref.watch(governmentRepositoryProvider);
  final result = await repository.getAllServices(
    page: 1,
    pageSize: 20,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (services) => services,
  );
});

final popularServicesProvider =
    FutureProvider<List<GovernmentService>>((ref) async {
  final repository = ref.watch(governmentRepositoryProvider);
  final result = await repository.getPopularServices(limit: 10);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (services) => services,
  );
});

final searchServicesProvider =
    FutureProvider.family<List<GovernmentService>, String>(
  (ref, query) async {
    final repository = ref.watch(governmentRepositoryProvider);
    final result = await repository.searchServices(
      query: query,
      page: 1,
      pageSize: 20,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (services) => services,
    );
  },
);

final servicesByCategoryProvider =
    FutureProvider.family<List<GovernmentService>, String>(
  (ref, category) async {
    final repository = ref.watch(governmentRepositoryProvider);
    final result = await repository.getServicesByCategory(
      category: category,
      page: 1,
      pageSize: 20,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (services) => services,
    );
  },
);

final governmentCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(governmentRepositoryProvider);
  final result = await repository.getCategories();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});
