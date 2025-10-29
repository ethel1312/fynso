import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'https://fynso.pythonanywhere.com';

  Future<String?> getFirstName(String jwt) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api_me_nombre'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'JWT $jwt', // <- flask_jwt
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
}
