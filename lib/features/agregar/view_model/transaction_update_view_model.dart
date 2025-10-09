import 'package:flutter/material.dart';
import '../../../data/models/transaction_response.dart';
import '../../../data/models/transaction_update_resquest.dart';
import '../../../data/repositories/transaction_repository.dart';

class TransactionEditViewModel extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  bool isLoading = false;
  String? error;

  TransactionResponse? transaction;

  /// Cargar datos iniciales (pasando un TransactionResponse desde pantalla anterior)
  void loadTransaction(TransactionResponse t) {
    transaction = t;
    notifyListeners();
  }

  /// Actualizar transacción
  Future<bool> updateTransaction({
    required String jwt,
    required int idTransaction,
    required TransactionUpdateRequest body,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final updated = await _repository.updateTransaction(
        jwt: jwt,
        idTransaction: idTransaction,
        body: body,
      );

      transaction = updated; // actualizar la transacción local
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
