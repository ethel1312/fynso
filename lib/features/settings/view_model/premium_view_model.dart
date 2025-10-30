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

  Future<String?> iniciarSuscripcion() async {
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
  }
}
