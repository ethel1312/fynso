// lib/data/repositories/transaction_detail_repository.dart
import '../models/transaction_detail_response.dart';
import '../services/transaction_detail_service.dart';

class TransactionDetailRepository {
  final TransactionDetailService _service = TransactionDetailService();

  Future<TransactionDetailResponse> fetchTransactionDetail({
    required String jwt,
    required int idTransaction,
  }) {
    return _service.getTransactionDetail(
      jwt: jwt,
      idTransaction: idTransaction,
    );
  }
}
