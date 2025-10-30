import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/register_request.dart';

class AuthService {
  final String baseUrl = 'https://fynso.pythonanywhere.com';

  Future<AuthResponse> login(AuthRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error en inicio de sesión: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequest body) async {
    final uri = Uri.parse('$baseUrl/api_registrar_usuario');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body.toJson()),
    );

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && jsonBody['code'] == 1) {
      return jsonBody;
    } else {
      throw Exception(jsonBody['message'] ?? 'Error al registrar usuario');
    }
  }
}
