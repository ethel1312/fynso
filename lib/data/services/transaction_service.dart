import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_response.dart';
import '../models/transactions_filter.dart';

class TransactionService {
  final String baseUrl = 'https://fynso.pythonanywhere.com';

  Future<List<TransactionResponse>> getTransactions({
    required String jwt,
    required int anio,
    required int mes,
    int page = 1,
    int size = 50,
    TransactionsFilter? filter,
  }) async {
    final qp = <String, String>{
      'anio': '$anio',
      'mes': '$mes',
      'page': '$page',
      'size': '$size',
      'type': 'Gasto', // por defecto
    };
    if (filter != null) {
      qp.addAll(filter.toQueryParams());
    }

    final uri = Uri.parse('$baseUrl/api/transactions').replace(queryParameters: qp);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'JWT $jwt', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (jsonBody['data']?['items'] as List?) ?? [];
      return items.map((e) => TransactionResponse.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener transacciones: ${response.statusCode}');
    }
  }

  // PATCH actualizar transacción (sin cambios)
  Future<TransactionResponse> updateTransaction({
    required String jwt,
    required int idTransaction,
    required Map<String, dynamic> body,
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
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final data = jsonBody['data'] as Map<String, dynamic>;
      return TransactionResponse.fromJson(data);
    } else {
      final jsonBody = jsonDecode(response.body);
      final message = jsonBody['message'] ?? 'Error al actualizar transacción';
      throw Exception(message);
    }
  }

  Future<bool> deleteTransaction({
    required String jwt,
    required int idTransaction,
  }) async {
    final uri = Uri.parse('$baseUrl/api/transactions/$idTransaction');
    final resp = await http.delete(
      uri,
      headers: {
        'Authorization': 'JWT $jwt',
        'Accept': 'application/json',
      },
    );

    if (resp.statusCode == 200) {
      final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
      final code = jsonBody['code'] ?? 0;
      if (code == 1) return true;
      final msg = (jsonBody['message'] ?? 'No se pudo eliminar') as String;
      throw Exception(msg);
    } else {
      throw Exception('Error al eliminar: ${resp.statusCode}');
    }
  }
}
