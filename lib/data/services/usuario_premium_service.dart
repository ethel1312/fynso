import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../common/utils/constants.dart';
import '../models/usuario_premium_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioPremiumService {

  Future<UsuarioPremium?> obtenerEstadoPremium({required String jwt}) async {
    final uri = Uri.parse('$AppConstants.baseUrl/api_usuario_premium_estado');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'JWT $jwt', // ⚠️ Bearer no JWT
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      print('🔹 Response Premium: $jsonBody'); // depuración
      return UsuarioPremium.fromJson(jsonBody['data']);
    } else {
      print('❌ Error premium: ${response.statusCode} ${response.body}');
      return null;
    }
  }
}
