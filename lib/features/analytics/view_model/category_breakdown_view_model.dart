import 'package:flutter/foundation.dart';
import 'package:fynso/data/repositories/analytics_repository.dart';
import 'package:fynso/data/services/analytics_service.dart';

class CategoryBreakdownViewModel extends ChangeNotifier {
  final AnalyticsRepository _repo = AnalyticsRepository();

  bool loading = false;
  String? error;
  CategoryBreakdownResponse? data;

  Future<void> load({
    required String jwt,
    required int anio,
    required int mes,
    int top = 5,
  }) async {
    if (jwt.isEmpty) {
      error = 'Sesión no iniciada';
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    notifyListeners();

    try {
      data = await _repo.fetchCategoryBreakdown(
        jwt: jwt,
        anio: anio,
        mes: mes,
        top: top,
      );
    } catch (e) {
      error = 'No se pudo cargar el desglose';
      data = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
