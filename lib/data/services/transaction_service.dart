import 'dart:convert';
import 'package:fynso/data/models/transaction_response.dart';
import 'package:http/http.dart' as http;

class TransactionService {
  final String baseUrl = 'https://fynso.pythonanywhere.com';

  // GET transacciones
  Future<List<TransactionResponse>> getTransactions({
    required String jwt,
    required int anio,
    required int mes,
    int page = 1,
    int size = 50,
  }) async {
    final uri = Uri.parse('$baseUrl/api/transactions').replace(
      queryParameters: {
        'anio': anio.toString(),
        'mes': mes.toString(),
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'JWT $jwt', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final items = jsonBody['data']['items'] as List;
      return items.map((e) => TransactionResponse.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener transacciones: ${response.statusCode}');
    }
  }

  // PATCH actualizar transacción
  Future<TransactionResponse> updateTransaction({
    required String jwt,
    required int idTransaction,
    required Map<String, dynamic>
    body, // {"amount":123,"date":"2025-10-09", ...}
  }) async {
    final uri = Uri.parse('$baseUrl/api/transactions/$idTransaction');

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'JWT $jwt',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final data = jsonBody['data'] as Map<String, dynamic>;
      return TransactionResponse.fromJson(data);
    } else {
      final jsonBody = jsonDecode(response.body);
      final message = jsonBody['message'] ?? 'Error al actualizar transacción';
      throw Exception(message);
    }
  }
}
