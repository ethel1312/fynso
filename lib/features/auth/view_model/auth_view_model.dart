import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- agregar
import '../../../data/models/auth_response.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  AuthResponse? _authResponse;

  AuthResponse? get authResponse => _authResponse;

  // LOGIN

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.login(username, password);
      _authResponse = result;

      // 🔹 Guardar token automáticamente en SharedPreferences
      if (_authResponse != null && _authResponse!.accessToken.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _authResponse!.accessToken);
        print(
          "✅ JWT guardado: ${_authResponse!.accessToken}",
        ); // <-- agrega esto
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // REGISTER

  Future<Map<String, dynamic>?> register(
    String username,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.register(username, email, password);
      return result; // Devuelve el JSON del backend: { code, message, data }
    } catch (e) {
      print('Error en AuthViewModel (register): $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // OBTENER TOKEN

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // LOGOUT

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _authResponse = null;
    notifyListeners();
  }
}
