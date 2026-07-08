import 'package:nai/src/utils/utils.dart';
import '../entities/government_service.dart';

abstract class GovernmentRepository {
  /// Fetch all government services
  FutureEither<List<GovernmentService>> getAllServices({
    required int page,
    required int pageSize,
  });

  /// Search government services by name or description
  FutureEither<List<GovernmentService>> searchServices({
    required String query,
    required int page,
    required int pageSize,
  });

  /// Get services by category
  FutureEither<List<GovernmentService>> getServicesByCategory({
    required String category,
    required int page,
    required int pageSize,
  });

  /// Get popular services
  FutureEither<List<GovernmentService>> getPopularServices({
    required int limit,
  });

  /// Get service details
  FutureEither<GovernmentService> getServiceDetails(String serviceId);

  /// Get available categories
  FutureEither<List<String>> getCategories();
}
