import 'package:dio/dio.dart';
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
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final services = (response.data['data'] as List?)
              ?.map((e) => GovernmentServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      return services;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<GovernmentServiceModel>> searchServices({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    // TODO: No real government-services search backend yet. Returns empty until wired.
    return [];
  }

  @override
  Future<List<GovernmentServiceModel>> getServicesByCategory({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    // TODO: No real government-services backend yet. Returns empty until wired.
    return [];
  }

  @override
  Future<List<GovernmentServiceModel>> getPopularServices({
    required int limit,
  }) async {
    // TODO: No real government-services backend yet. Returns empty until wired.
    return [];
  }

  @override
  Future<GovernmentServiceModel> getServiceDetails(String serviceId) async {
    throw UnimplementedError('Government service details endpoint not yet wired.');
  }

  @override
  Future<List<String>> getCategories() async {
    // TODO: No real government-services backend yet. Returns empty until wired.
    return [];
  }
}
