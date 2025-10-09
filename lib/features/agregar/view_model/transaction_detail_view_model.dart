// lib/features/agregar/view_model/detalle_gasto_view_model.dart
import 'package:flutter/material.dart';
import '../../../data/models/transaction_detail_response.dart';
import '../../../data/repositories/transaction_detail_repository.dart';

class TransactionDetailViewModel extends ChangeNotifier {
  final TransactionDetailRepository _repository = TransactionDetailRepository();

  bool isLoading = false;
  TransactionDetailResponse? transaction;
  String? error;

  Future<void> loadTransactionDetail({
    required String jwt,
    required int idTransaction,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      transaction = await _repository.fetchTransactionDetail(
        jwt: jwt,
        idTransaction: idTransaction,
      );
    } catch (e) {
      error = e.toString();
      transaction = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
