import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/monthly_summary.dart';

class MonthlySummaryService {
  final String baseUrl = 'https://fynso.pythonanywhere.com';

  Future<MonthlySummary> getMonthlySummary({
    required String jwt,
    required int anio,
    required int mes,
  }) async {
    final uri = Uri.parse('$baseUrl/api/monthly_summary')
        .replace(queryParameters: {'anio': '$anio', 'mes': '$mes'});

    final resp = await http
        .get(uri, headers: {'Authorization': 'JWT $jwt'})
        .timeout(const Duration(seconds: 12));

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if ((decoded['code'] ?? 0) != 1) {
      throw Exception(decoded['message'] ?? 'Error en monthly_summary');
    }
    return MonthlySummary.fromApi(decoded);
  }

  Future<void> setMonthlyLimit({
    required String jwt,
    required int anio,
    required int mes,
    required double limite,
  }) async {
    final uri = Uri.parse('$baseUrl/api/monthly_limit');
    final body = jsonEncode({'anio': anio, 'mes': mes, 'limite': limite});

    final resp = await http
        .post(
      uri,
      headers: {
        'Authorization': 'JWT $jwt',
        'Content-Type': 'application/json',
      },
      body: body,
    )
        .timeout(const Duration(seconds: 12));

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if ((decoded['code'] ?? 0) != 1) {
      throw Exception(decoded['message'] ?? 'No se pudo guardar el límite');
    }
  }

  Future<void> closeMonth({
    required String jwt,
    required int anio,
    required int mes,
  }) async {
    final uri = Uri.parse('$baseUrl/api/monthly_limit/close');
    final body = jsonEncode({'anio': anio, 'mes': mes});

    final resp = await http
        .post(
      uri,
      headers: {
        'Authorization': 'JWT $jwt',
        'Content-Type': 'application/json',
      },
      body: body,
    )
        .timeout(const Duration(seconds: 12));

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if ((decoded['code'] ?? 0) != 1) {
      throw Exception(decoded['message'] ?? 'No se pudo cerrar el mes');
    }
  }

  Future<void> reconcileMonthly({
    required String jwt,
    required String tzName,
    required String nowIso,
    required bool applyDefaultLimit,
    required double defaultLimit,
  }) async {
    final uri = Uri.parse('$baseUrl/api/monthly_limit/reconcile');
    final body = jsonEncode({
      'tz_name': tzName,
      'now_iso': nowIso,
      'apply_default_limit': applyDefaultLimit,
      'default_limit': defaultLimit,
    });

    final resp = await http
        .post(
      uri,
      headers: {
        'Authorization': 'JWT $jwt',
        'Content-Type': 'application/json',
      },
      body: body,
    )
        .timeout(const Duration(seconds: 15));

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if ((decoded['code'] ?? 0) != 1) {
      throw Exception(decoded['message'] ?? 'No se pudo reconciliar');
    }
  }
}
