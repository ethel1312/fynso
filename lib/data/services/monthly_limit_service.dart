import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../common/utils/constants.dart';

class MonthlyLimitService {

  // === Reconcile (sin now_iso) ===
  Future<void> reconcile({
    required String jwt,
    required String tzName,
    bool applyDefaultLimit = false,
    String defaultLimit = '0.00',
  }) async {
    final uri = Uri.parse('$AppConstants.baseUrl/api/monthly_limit/reconcile');
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
      // opcional: lanza o loguea
      // throw Exception('Reconcile failed: ${res.body}');
    }
  }

  // === GET default_monthly_limit del usuario ===
  Future<({bool enabled, double defaultLimit})> getDefaultMonthlyLimit({
    required String jwt,
  }) async {
    final uri = Uri.parse('$AppConstants.baseUrl/api/user/default_monthly_limit');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'JWT $jwt'},
    );
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final j = json.decode(res.body) as Map<String, dynamic>;
    if ((j['code'] ?? 0) != 1) {
      throw Exception(j['message'] ?? 'Error al leer default_monthly_limit');
    }
    final data = j['data'] as Map<String, dynamic>? ?? {};
    final enabled = data['enabled'] == true;
    final dlStr = data['default_limit'];
    final dl = (dlStr == null) ? 0.0 : double.tryParse(dlStr.toString()) ?? 0.0;
    return (enabled: enabled, defaultLimit: dl);
  }

  // === POST default_monthly_limit del usuario ===
  Future<bool> setDefaultMonthlyLimit({
    required String jwt,
    required bool enabled,
    required double defaultLimit,
  }) async {
    final uri = Uri.parse('$AppConstants.baseUrl/api/user/default_monthly_limit');
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'JWT $jwt',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'enabled': enabled,
        'default_limit': defaultLimit,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final j = json.decode(res.body) as Map<String, dynamic>;
    return (j['code'] ?? 0) == 1;
  }
}
