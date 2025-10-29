import '../models/transaction_update_resquest.dart';
import '../services/transaction_service.dart';
import '../models/transaction_response.dart';
import '../models/transactions_filter.dart';

class TransactionRepository {
  final TransactionService _service = TransactionService();

  Future<List<TransactionResponse>> fetchTransactions({
    required String jwt,
    required int anio,
    required int mes,
    int page = 1,
    int size = 50,
    TransactionsFilter? filter,
  }) {
    return _service.getTransactions(
      jwt: jwt,
      anio: anio,
      mes: mes,
      page: page,
      size: size,
      filter: filter,
    );
  }

  Future<TransactionResponse> updateTransaction({
    required String jwt,
    required int idTransaction,
    required TransactionUpdateRequest body,
  }) {
    return _service.updateTransaction(
      jwt: jwt,
      idTransaction: idTransaction,
      body: body.toJson(),
    );
  }
}
