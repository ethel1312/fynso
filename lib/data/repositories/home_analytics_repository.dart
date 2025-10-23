import '../models/top_categories_response.dart';
import '../services/home_analytics_service.dart';

class HomeAnalyticsRepository {
  final HomeAnalyticsService _service = HomeAnalyticsService();

  Future<TopCategoriesResponse> fetchTopCategories({
    required String jwt,
    int? year,
    int? month,
    int topN = 4,
  }) {
    return _service.getTopCategories(
      jwt: jwt,
      year: year,
      month: month,
      topN: topN,
    );
  }
}
