import 'package:flutter/material.dart';
import '../../../data/models/insights_response.dart';
import '../../../data/repositories/analytics_repository.dart';

class InsightsViewModel extends ChangeNotifier {
  final AnalyticsRepository _repo = AnalyticsRepository();

  bool loading = false;
  String? error;
  InsightsResponse? data;

  Future<void> load({required String jwt, int limit = 7}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      data = await _repo.fetchRecommendations(jwt: jwt, limit: limit);
    } catch (e) {
      error = e.toString();
      data = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

