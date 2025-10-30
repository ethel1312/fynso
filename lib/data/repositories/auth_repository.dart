import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/register_request.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<AuthResponse?> login(String username, String password) async {
    try {
      final request = AuthRequest(username: username, password: password);
      return await _authService.login(request);
    } catch (e) {
      print('Error en AuthRepository (login): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
      );
      return await _authService.register(request);
    } catch (e) {
      print('Error en AuthRepository (register): $e');
      return null;
    }
  }
}
