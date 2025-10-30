import '../services/analytics_service.dart';

class AnalyticsRepository {
  final AnalyticsService _service = AnalyticsService();

  Future<CategoryBreakdownResponse> fetchCategoryBreakdown({
    required String jwt,
    required int anio,
    required int mes,
    int top = 5,
  }) {
    return _service.getCategoryBreakdown(jwt: jwt, anio: anio, mes: mes, top: top);
  }
}
