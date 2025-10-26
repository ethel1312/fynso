import 'dart:convert';
import 'package:http/http.dart' as http;

class MonthlyLimitService {
  final String baseUrl = 'https://fynso.pythonanywhere.com';

  Future<void> reconcile({
    required String jwt,
    required String tzName,
    bool applyDefaultLimit = false,
    String defaultLimit = '0.00',
  }) async {
    final uri = Uri.parse('$baseUrl/api/monthly_limit/reconcile');
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'JWT $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tz_name': tzName,
        'apply_default_limit': applyDefaultLimit,
        'default_limit': defaultLimit,
      }),
    );

    if (res.statusCode != 200) {
      // opcional: lanza o sólo loguea
      // throw Exception('Reconcile failed: ${res.body}');
    }
  }
}
