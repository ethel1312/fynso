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
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Método opcional para obtener el token en cualquier parte
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // 🔹 Método opcional para cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _authResponse = null;
    notifyListeners();
  }
}
