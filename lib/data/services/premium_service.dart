// lib/data/services/premium_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pago_premium_model.dart';
import '../models/premium_status_response.dart';

class PremiumService {
  final String baseUrl = "https://fynso.pythonanywhere.com";

  Future<PagoPremium> iniciarSuscripcion({required String jwt}) async {
    final url = Uri.parse("$baseUrl/api_iniciar_suscripcion_premium");

    final response = await http.post(
      url,
      headers: {'Authorization': 'JWT $jwt', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PagoPremium.fromJson(data);
    } else {
      throw Exception("Error al iniciar suscripción: ${response.body}");
    }
  }

  Future<PremiumStatusResponse> verificarEstadoPremium({required String jwt}) async {
    final url = Uri.parse("$baseUrl/api_usuario_premium_estado");

    final response = await http.get(
      url,
      headers: {'Authorization': 'JWT $jwt', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if ((data['code'] ?? 0) != 1) {
        throw Exception(data['message'] ?? 'Error al verificar estado premium');
      }
      return PremiumStatusResponse.fromJson(data);
    } else {
      throw Exception("Error HTTP ${response.statusCode}");
    }
  }
}
