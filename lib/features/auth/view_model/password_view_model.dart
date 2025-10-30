import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class PasswordViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Email guardado temporalmente durante el flujo
  String? _temporaryEmail;
  String? get temporaryEmail => _temporaryEmail;

  void setTemporaryEmail(String email) {
    _temporaryEmail = email;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Enviar código de verificación
  Future<bool> sendVerificationCode(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.sendVerificationCode(email);

      if (result != null && result.code == 1) {
        _successMessage = result.message;
        _temporaryEmail = email;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result?.message ?? 'Error al enviar código';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verificar código
  Future<bool> verifyCode(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.verifyCode(email, code);

      if (result != null && result.code == 1) {
        _successMessage = result.message;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result?.message ?? 'Código incorrecto';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Actualizar contraseña
  Future<bool> updatePassword(String email, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.updatePassword(email, newPassword);

      if (result != null && result.code == 1) {
        _successMessage = result.message;
        _temporaryEmail = null; // Limpiamos el email temporal
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result?.message ?? 'Error al actualizar contraseña';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
