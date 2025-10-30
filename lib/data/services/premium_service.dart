// lib/data/services/premium_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pago_premium_model.dart';

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
}
