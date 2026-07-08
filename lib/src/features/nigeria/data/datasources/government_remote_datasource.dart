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
  final Dio _dio = Dio();

  @override
  Future<List<GovernmentServiceModel>> getAllServices({
    required int page,
    required int pageSize,
  }) async {
    try {
      // Try backend first
      final response = await AppConfig.dio.get(
        '/government/services',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

      final services = (response.data['data'] as List?)
              ?.map((e) => GovernmentServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
          
      if (services.isNotEmpty) return services;
      
      return _getFallbackServices();
      
    } catch (_) {
      return _getFallbackServices();
    }
  }

  List<GovernmentServiceModel> _getFallbackServices() {
    return [
      GovernmentServiceModel(
        id: '1',
        name: 'NIN Registration',
        description: 'National Identification Number registration and management.',
        category: 'Identity',
        url: 'https://nimc.gov.ng',
        icon: 'badge',
      ),
      GovernmentServiceModel(
        id: '2',
        name: 'Passport Application',
        description: 'Apply for or renew your Nigerian passport.',
        category: 'Travel',
        url: 'https://immigration.gov.ng',
        icon: 'travel',
      ),
      GovernmentServiceModel(
        id: '3',
        name: 'Tax Filing',
        description: 'File your taxes online with the Federal Inland Revenue Service.',
        category: 'Finance',
        url: 'https://firs.gov.ng',
        icon: 'payments',
      ),
      GovernmentServiceModel(
        id: '4',
        name: 'Business Registration',
        description: 'Register your business with the Corporate Affairs Commission.',
        category: 'Business',
        url: 'https://cac.gov.ng',
        icon: 'store',
      ),
      GovernmentServiceModel(
        id: '5',
        name: 'Driver\'s License',
        description: 'Apply for or renew your driver\'s license.',
        category: 'Transport',
        url: 'https://frsc.gov.ng',
        icon: 'directions_car',
      ),
    ];
  }
}
