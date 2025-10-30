import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fynso/data/models/monthly_spending_trend.dart';
import 'package:fynso/data/models/insights_response.dart';
import 'package:fynso/data/models/category_status_response.dart';

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
  final double? limiteActual;            // 👈 ahora nullable
  final double totalMes;
  final bool hasUserDefaultLimit;        // 👈 nuevo
  final List<CategoryBreakdownItem> items;
  final List<CategoryBreakdownItem> topItems;

  CategoryBreakdownResponse({
    required this.anio,
    required this.mes,
    required this.limiteActual,
    required this.totalMes,
    required this.hasUserDefaultLimit,
    required this.items,
    required this.topItems,
  });

  factory CategoryBreakdownResponse.fromJson(Map<String, dynamic> j) {
    Iterable it = (j['items'] as List? ?? []);
    Iterable top = (j['top_items'] as List? ?? []);
    final lim = j['limite_actual']; // puede ser null
    return CategoryBreakdownResponse(
      anio: j['anio'] as int,
      mes: j['mes'] as int,
      limiteActual: (lim == null) ? null : ((lim is num) ? lim.toDouble() : double.tryParse('$lim')),
      totalMes: (j['total_mes'] as num?)?.toDouble() ?? 0.0,
      hasUserDefaultLimit: (j['has_user_default_limit'] as bool?) ?? false,
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

  Future<MonthlySpendingTrendResponse> getMonthlySpendingLast6PlusCurrent({
    required String jwt,
  }) async {
    final uri = Uri.parse('$baseUrl/api/analytics/monthly_spending_last6_plus_current');

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'JWT $jwt', 'Accept': 'application/json'},
    );

    if (resp.statusCode != 200) {
      throw Exception('Error HTTP ${resp.statusCode}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if ((decoded['code'] ?? 0) != 1) {
      throw Exception(decoded['message']?.toString() ?? 'Error en tendencia mensual');
    }

    return MonthlySpendingTrendResponse.fromJson(decoded);
  }

  Future<InsightsResponse> getRecommendations({
    required String jwt,
    int limit = 7,
    bool shuffle = false,
    String? tzName,
  }) async {
    final uri = Uri.parse('$baseUrl/api/insights/recommendations')
        .replace(queryParameters: {
      'limit': '$limit',
      'shuffle': shuffle ? '1' : '0',
      if (tzName != null) 'tz_name': tzName,
    });

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'JWT $jwt', 'Accept': 'application/json'},
    );

    if (resp.statusCode != 200) {
      throw Exception('Error HTTP ${resp.statusCode}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if ((decoded['code'] ?? 0) != 1) {
      throw Exception(decoded['message']?.toString() ?? 'Error en recomendaciones');
    }

    return InsightsResponse.fromJson(decoded);
  }

  Future<CategoryStatusResponse> getCategoryStatusCards({
    required String jwt,
    int? anio,
    int? mes,
    double minAmount = 50.00,
  }) async {
    final queryParams = <String, String>{
      'min_amount': '$minAmount',
    };
    if (anio != null) queryParams['anio'] = '$anio';
    if (mes != null) queryParams['mes'] = '$mes';

    final uri = Uri.parse('$baseUrl/api/analytics/category_status_cards')
        .replace(queryParameters: queryParams);

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'JWT $jwt', 'Accept': 'application/json'},
    );

    if (resp.statusCode != 200) {
      throw Exception('Error HTTP ${resp.statusCode}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if ((decoded['code'] ?? 0) != 1) {
      throw Exception(decoded['message']?.toString() ?? 'Error en category status');
    }

    return CategoryStatusResponse.fromJson(decoded);
  }
}
