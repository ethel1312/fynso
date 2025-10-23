import 'package:flutter/material.dart';
import '../../../data/models/top_categories_response.dart';
import '../../../data/repositories/home_analytics_repository.dart';

class DonutChartViewModel extends ChangeNotifier {
  final HomeAnalyticsRepository _repo = HomeAnalyticsRepository();

  bool isLoading = false;
  String? error;

  int anio = 0;
  int mes = 0;
  String total = '0.00';
  List<TopCategoryItem> items = [];

  // Config de colores fijos
  static const String _restLabel = 'Resto';
  final List<Color> _fixedOrder = const [Colors.red, Colors.blue, Colors.green, Colors.orange];
  final Color _restColor = Colors.grey;

  // Devuelve color estable por posición (no por nombre):
  // - Cuenta solo los no-"Resto" para asignar red/blue/green/orange en ese orden.
  // - "Resto" siempre gris, esté donde esté.
  Color colorForIndex(int index) {
    final lower = (items[index].nombre).trim().toLowerCase();
    if (lower == _restLabel.toLowerCase()) return _restColor;

    // Índice entre los no-Resto hasta 'index'
    int nonRestRank = 0;
    for (int i = 0; i <= index; i++) {
      final isRest = items[i].nombre.trim().toLowerCase() == _restLabel.toLowerCase();
      if (!isRest) nonRestRank++;
    }
    // nonRestRank es 1-based; pásalo a 0-based
    final colorIdx = (nonRestRank - 1).clamp(0, _fixedOrder.length - 1);
    return _fixedOrder[colorIdx];
  }

  Future<void> load({required String jwt, int? year, int? month}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _repo.fetchTopCategories(jwt: jwt, year: year, month: month, topN: 4);
      anio = res.anio;
      mes = res.mes;
      total = res.total;
      items = res.items;
    } catch (e) {
      error = e.toString();
      items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
