import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryBreakdownItem {
  final int idCategory;
  final String nombre;
  final double montoMes;
  final double montoMesAnterior;
  final double ratioMes;
  final double ratioMesAnterior;

  CategoryBreakdownItem({
    required this.idCategory,
    required this.nombre,
    required this.montoMes,
    required this.montoMesAnterior,
    required this.ratioMes,
    required this.ratioMesAnterior,
  });

  factory CategoryBreakdownItem.fromJson(Map<String, dynamic> j) {
    double _d(v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    return CategoryBreakdownItem(
      idCategory: j['id_category'] as int,
      nombre: j['nombre'] as String,
      montoMes: _d(j['monto_mes']),
      montoMesAnterior: _d(j['monto_mes_anterior']),
      ratioMes: _d(j['ratio_mes']),
      ratioMesAnterior: _d(j['ratio_mes_anterior']),
    );
  }
}

class CategoryBreakdownResponse {
  final int anio;
  final int mes;
  final double limiteActual;
  final double totalMes;
  final List<CategoryBreakdownItem> items;
  final List<CategoryBreakdownItem> topItems;

  CategoryBreakdownResponse({
    required this.anio,
    required this.mes,
    required this.limiteActual,
    required this.totalMes,
    required this.items,
    required this.topItems,
  });

  factory CategoryBreakdownResponse.fromJson(Map<String, dynamic> j) {
    Iterable it = (j['items'] as List? ?? []);
    Iterable top = (j['top_items'] as List? ?? []);
    return CategoryBreakdownResponse(
      anio: j['anio'] as int,
      mes: j['mes'] as int,
      limiteActual: (j['limite_actual'] as num?)?.toDouble() ?? 0.0,
      totalMes: (j['total_mes'] as num?)?.toDouble() ?? 0.0,
      items: it.map((e) => CategoryBreakdownItem.fromJson(e)).toList(),
      topItems: top.map((e) => CategoryBreakdownItem.fromJson(e)).toList(),
    );
  }
}

class AnalyticsService {
  final String baseUrl = 'https://fynso.pythonanywhere.com';

  Future<CategoryBreakdownResponse> getCategoryBreakdown({
    required String jwt,
    required int anio,
    required int mes,
    int top = 5,
  }) async {
    final uri = Uri.parse('$baseUrl/api/analytics/category-breakdown')
        .replace(queryParameters: {
      'anio': '$anio',
      'mes': '$mes',
      'top': '$top',
    });

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'JWT $jwt', 'Accept': 'application/json'},
    );

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      if (decoded['code'] != 1) {
        throw Exception(decoded['message'] ?? 'Error');
      }
      return CategoryBreakdownResponse.fromJson(decoded['data']);
    } else {
      throw Exception('Error HTTP ${resp.statusCode}');
    }
  }
}
