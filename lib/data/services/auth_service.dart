import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_request.dart';
import '../models/auth_response.dart';

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
}
