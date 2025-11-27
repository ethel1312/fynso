import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- agregar
import '../../../data/models/auth_response.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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

      // 🔹 Guardar token y email/username automáticamente en SharedPreferences
      if (_authResponse != null && _authResponse!.accessToken.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _authResponse!.accessToken);
        await prefs.setString('user_email', username); // Guardar email/username
        print(
          "✅ JWT guardado: ${_authResponse!.accessToken}",
        ); // <-- agrega esto
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // En AuthViewModel
  Future<AuthResponse?> loginWithGoogle(String idToken) async {
    try {
      final repo = AuthRepository();
      return await repo.loginWithGoogle(idToken); // <-- llamas a tu API backend
    } catch (e) {
      print("Error en loginWithGoogle: $e");
      return null;
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
    await prefs.remove('user_email');

    // 🔹 Cerrar sesión de Google (si el usuario estaba logueado por Google)
    try {
      await _googleSignIn.signOut();
      print("✔ Sesión de Google cerrada");
    } catch (e) {
      print("❌ Error al cerrar sesión de Google: $e");
    }

    _authResponse = null;
    notifyListeners();
  }

  Future<bool> loginWithGoogle(String idToken, String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.loginWithGoogle(idToken);
      _authResponse = result;

      if (_authResponse != null && _authResponse!.accessToken.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _authResponse!.accessToken);
        await prefs.setString('user_email', email); // guarda email Google
        print("✅ JWT (Google) guardado: ${_authResponse!.accessToken}");
        return true;
      }

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
