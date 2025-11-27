import 'dart:convert';
import 'package:fynso/data/models/api_response.dart';
import 'package:http/http.dart' as http;
import '../../common/config.dart';
import '../models/income_request.dart';

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
}
