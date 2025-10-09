import 'package:flutter/material.dart';
import 'package:fynso/data/models/transaction_response.dart';
import '../../../data/repositories/transaction_repository.dart';

class HistorialGastosViewModel extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  bool isLoading = false;
  List<TransactionResponse> transactions = [];

  Future<void> loadTransactions({
    required String jwt,
    required int anio,
    required int mes,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      transactions = await _repository.fetchTransactions(
        jwt: jwt,
        anio: anio,
        mes: mes,
      );
    } catch (e) {
      print('Error al cargar transacciones: $e');
      transactions = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
