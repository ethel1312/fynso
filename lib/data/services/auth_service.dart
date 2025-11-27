import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/register_request.dart';
import '../models/send_code_request.dart';
import '../models/verify_code_request.dart';
import '../models/update_password_request.dart';

class AuthService {
  final String baseUrl = 'https://www.fynso.app';

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

  // Enviar código de verificación al email
  Future<ApiResponse> sendVerificationCode(SendCodeRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api_enviar_codigo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al enviar código: ${response.statusCode}');
    }
  }

  // Verificar código de verificación
  Future<ApiResponse> verifyCode(VerifyCodeRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api_verificar_codigo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al verificar código: ${response.statusCode}');
    }
  }

  // Actualizar contraseña
  Future<ApiResponse> updatePassword(UpdatePasswordRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api_actualizar_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar contraseña: ${response.statusCode}');
    }
  }
}
