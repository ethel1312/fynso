import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/premium_repository.dart';

class PremiumViewModel extends ChangeNotifier {
  final PremiumRepository _repository = PremiumRepository();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPremium = false; // ✅ privado, con getter

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isPremium => _isPremium;

  /// 🔹 Verifica si el usuario tiene una suscripción Premium activa
  Future<void> verificarEstadoPremium() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');

      if (jwt == null) {
        _errorMessage = "No hay JWT disponible";
        _isPremium = false;
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://fynso.pythonanywhere.com/api_usuario_premium_estado',
        ),
        headers: {'Authorization': 'Bearer $jwt'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Respuesta API Premium: $data"); // 🔹 Aquí
        _isPremium = data['data']['is_premium'] == true;
      } else {
        _isPremium = false;
        _errorMessage = 'Error en el servidor: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = "Error verificando estado premium: $e";
      _isPremium = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Inicia la suscripción Premium (tu versión original)
  Future<String?> iniciarSuscripcion() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');
      if (jwt == null) {
        _errorMessage = "No hay JWT disponible";
        return _errorMessage;
      }

      final result = await _repository.iniciarSuscripcion(jwt: jwt);

      if (result.checkoutUrl != null && result.checkoutUrl!.isNotEmpty) {
        final url = Uri.parse(result.checkoutUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
        return null; // sin error
      } else {
        _errorMessage = result.message.isNotEmpty
            ? result.message
            : "Error desconocido al iniciar suscripción";
        return _errorMessage;
      }
    } catch (e) {
      _errorMessage = "Error: $e";
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
