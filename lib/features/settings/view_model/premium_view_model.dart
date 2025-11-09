import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/repositories/premium_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumViewModel extends ChangeNotifier {
  final PremiumRepository _repository = PremiumRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  /// 🔹 Helper para obtener JWT
  Future<String?> _getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /*Future<String?> iniciarSuscripcion() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 🔹 Obtener JWT automáticamente
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');
      if (jwt == null) {
        _errorMessage = "No hay JWT disponible";
        return _errorMessage;
      }

      // 🔹 Llamar al repositorio con el JWT
      final result = await _repository.iniciarSuscripcion(jwt: jwt);

      if (result.checkoutUrl != null && result.checkoutUrl!.isNotEmpty) {
        final url = Uri.parse(result.checkoutUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
        return null; // Sin error
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
  }*/

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
        return result.checkoutUrl; // ✅ devolvemos la URL al caller
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

  /// 🔹 Confirma el pago en tu backend (PythonAnywhere)
  Future<String?> confirmarPago({required String jwt}) async {
    try {
      final response = await _repository.confirmarPago(jwt: jwt);
      if (response.statusCode == 200) {
        return null; // ✅ Todo bien
      } else {
        return "Error del servidor: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
