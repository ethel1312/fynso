import 'package:flutter/material.dart';
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

    final result = await _repository.login(username, password);

    _authResponse = result;
    _isLoading = false;
    notifyListeners();
  }
}
