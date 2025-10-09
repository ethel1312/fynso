import '../models/transaction_update_resquest.dart';
import '../services/transaction_service.dart';
import '../models/transaction_response.dart';

class TransactionRepository {
  final TransactionService _service = TransactionService();

  // ✅ Obtener transacciones
  Future<List<TransactionResponse>> fetchTransactions({
    required String jwt,
    required int anio,
    required int mes,
  }) {
    return _service.getTransactions(jwt: jwt, anio: anio, mes: mes);
  }

  // ✅ Actualizar transacción (devuelve TransactionResponse tipado)
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
