import 'package:nai/src/config/app_config.dart';
import '../models/government_service_model.dart';

abstract class GovernmentRemoteDataSource {
  Future<List<GovernmentServiceModel>> getAllServices({
    required int page,
    required int pageSize,
  });

  Future<List<GovernmentServiceModel>> searchServices({
    required String query,
    required int page,
    required int pageSize,
  });

  Future<List<GovernmentServiceModel>> getServicesByCategory({
    required String category,
    required int page,
    required int pageSize,
  });

  Future<List<GovernmentServiceModel>> getPopularServices({
    required int limit,
  });

  Future<GovernmentServiceModel> getServiceDetails(String serviceId);

  Future<List<String>> getCategories();
}

class GovernmentRemoteDataSourceImpl implements GovernmentRemoteDataSource {
  GovernmentRemoteDataSourceImpl();

  @override
  Future<List<GovernmentServiceModel>> getAllServices({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/government/services',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final services = (response.data['data'] as List?)
              ?.map((e) =>
                  GovernmentServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return services;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<GovernmentServiceModel>> searchServices({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/government/services/search',
        queryParameters: {
          'q': query,
          'page': page,
          'pageSize': pageSize,
        },
      );

      final services = (response.data['data'] as List?)
              ?.map((e) =>
                  GovernmentServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return services;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<GovernmentServiceModel>> getServicesByCategory({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/government/services/category/$category',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final services = (response.data['data'] as List?)
              ?.map((e) =>
                  GovernmentServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return services;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<GovernmentServiceModel>> getPopularServices({
    required int limit,
  }) async {
    try {
      final response = await AppConfig.dio.get(
        '/government/services/popular',
        queryParameters: {'limit': limit},
      );

      final services = (response.data['data'] as List?)
              ?.map((e) =>
                  GovernmentServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return services;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GovernmentServiceModel> getServiceDetails(String serviceId) async {
    try {
      final response = await AppConfig.dio.get(
        '/government/services/$serviceId',
      );

      final service = GovernmentServiceModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
      return service;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await AppConfig.dio.get(
        '/government/categories',
      );

      final categories = List<String>.from(
          response.data['data'] as List? ?? []);
      return categories;
    } catch (e) {
      rethrow;
    }
  }
}
