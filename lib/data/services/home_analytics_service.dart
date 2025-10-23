import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/top_categories_response.dart';

class HomeAnalyticsService {
  final String baseUrl = 'https://fynso.pythonanywhere.com';

  Future<TopCategoriesResponse> getTopCategories({
    required String jwt,
    int? year,
    int? month,
    int topN = 4,
  }) async {
    final qp = <String, String>{'top_n': '$topN'};
    if (year != null) qp['year'] = '$year';
    if (month != null) qp['month'] = '$month';

    final uri = Uri.parse('$baseUrl/api/analytics/top_categories')
        .replace(queryParameters: qp);

    try {
      final resp = await http
          .get(uri, headers: {'Authorization': 'JWT $jwt'})
          .timeout(const Duration(seconds: 12));

      // Log útil mientras depuras (puedes quitar luego)
      // print('[GET] ${resp.statusCode} $uri');
      // print('BODY: ${resp.body}');

      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      } on FormatException {
        throw Exception('Respuesta no es JSON: ${resp.body}');
      }

      if ((decoded['code'] ?? 0) != 1) {
        final msg = decoded['message']?.toString() ?? 'Error en top categorías';
        throw Exception(msg);
      }

      return TopCategoriesResponse.fromJson(decoded);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado (timeout)');
    } catch (e) {
      // Re-lanza con detalle
      rethrow;
    }
  }
}
