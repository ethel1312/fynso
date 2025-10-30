import 'package:flutter/material.dart';
import '../../../data/models/category_status_response.dart';
import '../../../data/repositories/analytics_repository.dart';

class CategoryStatusViewModel extends ChangeNotifier {
  final AnalyticsRepository _repo = AnalyticsRepository();

  bool loading = false;
  String? error;
  CategoryStatusResponse? data;

  Future<void> load({
    required String jwt,
    int? anio,
    int? mes,
    double minAmount = 50.00,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    
    try {
      data = await _repo.fetchCategoryStatusCards(
        jwt: jwt,
        anio: anio,
        mes: mes,
        minAmount: minAmount,
      );
    } catch (e) {
      error = e.toString();
      data = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
