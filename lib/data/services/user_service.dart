import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'https://www.fynso.app';

  Future<String?> getFirstName(String jwt) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api_me_nombre'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'JWT $jwt',
      },
    );

    if (res.statusCode == 200) {
      final m = jsonDecode(res.body) as Map<String, dynamic>;
      if (m['code'] == 1 && m['data'] != null) {
        return (m['data']['primer_nombre'] as String?)?.trim();
      }
    }
    return null;
  }

  // Perfil: username y límite mensual actuales en un solo endpoint
  Future<MeUsernameLimit?> getUsernameAndLimit(String jwt) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/me_username_y_limite'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'JWT $jwt',
      },
    );

    if (res.statusCode == 200) {
      final m = jsonDecode(res.body) as Map<String, dynamic>;
      if ((m['code'] ?? 0) == 1) {
        final data = (m['data'] as Map<String, dynamic>?) ?? {};
        final username = (data['username'] as String?)?.trim();
        final anio = data['anio'] as int?;
        final mes = data['mes'] as int?;
        final limiteStr = data['limite'] as String?; // "250.00" | null
        final limite = limiteStr != null ? double.tryParse(limiteStr) : null;
        return MeUsernameLimit(
          username: username,
          anio: anio,
          mes: mes,
          limite: limite,
        );
      }
    }
    return null;
  }
}

class MeUsernameLimit {
  final String? username;
  final int? anio;
  final int? mes;
  final double? limite;

  const MeUsernameLimit({this.username, this.anio, this.mes, this.limite});
}
