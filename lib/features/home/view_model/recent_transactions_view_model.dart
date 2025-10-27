import 'package:flutter/material.dart';
import 'package:fynso/data/models/transaction_response.dart';
import 'package:fynso/data/repositories/transaction_repository.dart';

class RecentTransactionsViewModel extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();

  bool isLoading = false;
  String? error;
  List<TransactionResponse> items = [];

  Future<void> load({
    required String jwt,
    int? year,
    int? month,
    int limit = 5,
  }) async {
    if (jwt.isEmpty) {
      error = 'Sesión no iniciada';
      notifyListeners();
      return;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final y = year ?? now.year;
      final m = month ?? now.month;

      // Reusamos tu repo de transacciones (orden DESC por id en el backend)
      final list = await _repo.fetchTransactions(jwt: jwt, anio: y, mes: m);
      items = list.take(limit).toList();
    } catch (e) {
      error = 'No se pudieron cargar transacciones';
      items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
