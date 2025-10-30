import '../services/analytics_service.dart';
import '../models/monthly_spending_trend.dart';
import '../models/insights_response.dart';
import '../models/category_status_response.dart';

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

  Future<MonthlySpendingTrendResponse> fetchMonthlySpendingTrend({
    required String jwt,
  }) {
    return _service.getMonthlySpendingLast6PlusCurrent(jwt: jwt);
  }

  Future<InsightsResponse> fetchRecommendations({
    required String jwt,
    int limit = 7,
    bool shuffle = false,
    String? tzName,
  }) {
    return _service.getRecommendations(
      jwt: jwt,
      limit: limit,
      shuffle: shuffle,
      tzName: tzName,
    );
  }

  Future<CategoryStatusResponse> fetchCategoryStatusCards({
    required String jwt,
    int? anio,
    int? mes,
    double minAmount = 50.00,
  }) {
    return _service.getCategoryStatusCards(
      jwt: jwt,
      anio: anio,
      mes: mes,
      minAmount: minAmount,
    );
  }
}
