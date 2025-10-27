import 'dart:convert';
import 'transaction_response.dart';

class TranscribeResponse {
  final String transcript;
  final Map<String, dynamic> extracted;
  final int? createdTransactionId;
  final TransactionResponse? transaction; // prefetch
  final Map<String, dynamic>? monthSummary;

  TranscribeResponse({
    required this.transcript,
    required this.extracted,
    this.createdTransactionId,
    this.transaction,
    this.monthSummary,
  });

  factory TranscribeResponse.fromApi(Map<String, dynamic> root) {
    final data = (root['data'] ?? {}) as Map<String, dynamic>;
    final transcript = (data['transcript'] ?? '') as String;

    final extracted = Map<String, dynamic>.from(data['extracted'] ?? {});
    final createdId = data['created_transaction_id'] as int?;
    final txMap = data['transaction'] as Map<String, dynamic>?;

    TransactionResponse? tx;
    if (txMap != null) {
      tx = TransactionResponse.fromJson(txMap);
    }

    final ms = data['month_summary'] as Map<String, dynamic>?;

    return TranscribeResponse(
      transcript: transcript,
      extracted: extracted,
      createdTransactionId: createdId,
      transaction: tx,
      monthSummary: ms,
    );
  }

  // Alias por si en algún punto llamas desde un Map ya decodificado
  factory TranscribeResponse.fromJson(Map<String, dynamic> root) =>
      TranscribeResponse.fromApi(root);

  static TranscribeResponse fromJsonString(String body) {
    final root = jsonDecode(body) as Map<String, dynamic>;
    return TranscribeResponse.fromApi(root);
  }
}
