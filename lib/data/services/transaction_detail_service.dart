// lib/data/services/transaction_detail_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_detail_response.dart';

class TransactionDetailService {
  final String baseUrl = 'https://www.fynso.app';

  Future<TransactionDetailResponse> getTransactionDetail({
    required String jwt,
    required int idTransaction,
  }) async {
    final uri = Uri.parse('$baseUrl/api/transactions/$idTransaction');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'JWT $jwt', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return TransactionDetailResponse.fromJson(jsonBody['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Transacción no encontrada');
    } else {
      throw Exception('Error al obtener transacción: ${response.statusCode}');
    }
  }
}
