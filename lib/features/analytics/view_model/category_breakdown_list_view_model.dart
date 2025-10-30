import 'package:flutter/foundation.dart';
import 'package:fynso/data/repositories/analytics_repository.dart';
import 'package:fynso/data/services/analytics_service.dart';

class CategoryBreakdownListViewModel extends ChangeNotifier {
  final AnalyticsRepository _repo = AnalyticsRepository();

  bool loading = false;
  String? error;
  CategoryBreakdownResponse? data;

  late String _jwt;
  late int anio;
  late int mes;

  Future<void> init({
    required String jwt,
    int? anio,
    int? mes,
  }) async {
    _jwt = jwt;
    final now = DateTime.now();
    this.anio = anio ?? now.year;
    this.mes = mes ?? now.month;
    await load();
  }

  Future<void> load() async {
    if ((_jwt).isEmpty) {
      error = 'Sesión no iniciada';
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      data = await _repo.fetchCategoryBreakdown(
        jwt: _jwt,
        anio: anio,
        mes: mes,
        top: 5, // top solo afecta "top_items"; aquí usaremos "items" (todas)
      );
    } catch (e) {
      error = 'No se pudo cargar el desglose';
      data = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> prevMonth() async {
    if (mes == 1) {
      mes = 12;
      anio -= 1;
    } else {
      mes -= 1;
    }
    await load();
  }

  Future<void> nextMonth() async {
    if (mes == 12) {
      mes = 1;
      anio += 1;
    } else {
      mes += 1;
    }
    await load();
  }
}
