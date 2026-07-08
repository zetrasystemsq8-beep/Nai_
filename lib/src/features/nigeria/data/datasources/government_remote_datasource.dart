import 'package:dio/dio.dart';
import 'package:nai/src/config/app_config.dart';
import '../models/government_service_model.dart';

abstract class GovernmentRemoteDataSource {
  Future<List<GovernmentServiceModel>> getAllServices({
    required int page,
    required int pageSize,
  });
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
      rethrow;
    }
  }
}
