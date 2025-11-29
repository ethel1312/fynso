import 'dart:convert';
import 'package:fynso/data/models/api_response.dart';
import 'package:http/http.dart' as http;

import '../../common/config.dart';
import '../models/income_request.dart';
import '../models/income_detail.dart';
import '../models/income_update_request.dart';

class IncomeService {
  final String baseUrl = Config.baseUrl;

  Future<ApiResponse> registrarIngreso({
    required String jwt,
    required IncomeRequest req,
  }) async {
    final uri = Uri.parse('$baseUrl/api_registrar_ingreso');

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "JWT $jwt",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(req.toJson()),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse.fromJson(jsonBody);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body["message"] ?? "Error al registrar ingreso");
    }
  }

  // 🔹 Obtener detalle de un ingreso
  Future<IncomeDetail> obtenerIngreso({
    required String jwt,
    required int idIncome,
  }) async {
    final uri = Uri.parse('$baseUrl/api/incomes/detail');

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "JWT $jwt",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({'id_income': idIncome}),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      if ((jsonBody['code'] ?? 0) != 1) {
        throw Exception(jsonBody['message'] ?? 'No se pudo obtener ingreso');
      }
      return IncomeDetail.fromJson(jsonBody['data']);
    } else {
      throw Exception(
        'Error HTTP ${response.statusCode}: ${response.body}',
      );
    }
  }

  // 🔹 Actualizar un ingreso
  Future<ApiResponse> actualizarIngreso({
    required String jwt,
    required int idIncome,
    required IncomeUpdateRequest req,
  }) async {
    final uri = Uri.parse('$baseUrl/api/incomes/update');

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "JWT $jwt",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        'id_income': idIncome,
        ...req.toJson(),
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(body);
    } else {
      throw Exception(body["message"] ?? "Error al actualizar ingreso");
    }
  }

  // 🔹 Eliminar un ingreso
  Future<ApiResponse> eliminarIngreso({
    required String jwt,
    required int idIncome,
  }) async {
    final uri = Uri.parse('$baseUrl/api/incomes/delete');

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "JWT $jwt",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({'id_income': idIncome}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(body);
    } else {
      throw Exception(body["message"] ?? "Error al eliminar ingreso");
    }
  }
}
