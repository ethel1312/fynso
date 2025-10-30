// lib/features/settings/view_model/usuario_premium_view_model.dart
import 'package:flutter/material.dart';
import '../../../data/repositories/usuario_premium_repository.dart';
import '../../../data/models/usuario_premium_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioPremiumViewModel extends ChangeNotifier {
  final UsuarioPremiumRepository _repository = UsuarioPremiumRepository();

  bool _isLoading = false;
  bool _isPremium = false;

  bool get isLoading => _isLoading;

  bool get isPremium => _isPremium;

  Future<void> verificarEstadoPremium() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');
      if (jwt == null) throw Exception('JWT no disponible');

      final usuario = await _repository.fetchEstadoPremium(jwt: jwt);
      _isPremium = usuario?.isPremium ?? false;
      print('🔹 isPremium: $_isPremium'); // depuración
    } catch (e) {
      _isPremium = false;
      print('❌ Error PremiumViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
