import '../models/api_response.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/register_request.dart';
import '../models/send_code_request.dart';
import '../models/verify_code_request.dart';
import '../models/update_password_request.dart';
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

  Future<AuthResponse?> loginWithGoogle(String idToken) async {
    try {
      return await _authService.loginWithGoogle(idToken);
    } catch (e) {
      print("Error en loginWithGoogle: $e");
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

  // Enviar código de verificación
  Future<ApiResponse?> sendVerificationCode(String email) async {
    try {
      final request = SendCodeRequest(email: email);
      return await _authService.sendVerificationCode(request);
    } catch (e) {
      print('Error en AuthRepository (sendVerificationCode): $e');
      return null;
    }
  }

  // Verificar código
  Future<ApiResponse?> verifyCode(String email, String code) async {
    try {
      final request = VerifyCodeRequest(email: email, code: code);
      return await _authService.verifyCode(request);
    } catch (e) {
      print('Error en AuthRepository (verifyCode): $e');
      return null;
    }
  }

  // Actualizar contraseña
  Future<ApiResponse?> updatePassword(String email, String newPassword) async {
    try {
      final request = UpdatePasswordRequest(
        email: email,
        newPassword: newPassword,
      );
      return await _authService.updatePassword(request);
    } catch (e) {
      print('Error en AuthRepository (updatePassword): $e');
      return null;
    }
  }

  Future<AuthResponse?> loginWithGoogle(String idToken) async {
    try {
      return await _authService.loginWithGoogle(idToken);
    } catch (e) {
      print('Error en AuthRepository (loginWithGoogle): $e');
      return null;
    }
  }

}
