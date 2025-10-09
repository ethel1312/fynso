import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<AuthResponse?> login(String username, String password) async {
    try {
      final request = AuthRequest(username: username, password: password);
      return await _authService.login(request);
    } catch (e) {
      print('Error en AuthRepository: $e');
      return null;
    }
  }
}
