import 'transaction_response.dart';

class CreateTransactionResponse {
  final int code;
  final String message;
  final CreateTransactionData? data;

  CreateTransactionResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory CreateTransactionResponse.fromJson(Map<String, dynamic> json) {
    return CreateTransactionResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CreateTransactionData.fromJson(json['data'])
          : null,
    );
  }
}

class CreateTransactionData {
  final int? createdTransactionId;
  final TransactionResponse? transaction;
  final MonthSummary? monthSummary;

  CreateTransactionData({
    this.createdTransactionId,
    this.transaction,
    this.monthSummary,
  });

  factory CreateTransactionData.fromJson(Map<String, dynamic> json) {
    return CreateTransactionData(
      createdTransactionId: json['created_transaction_id'],
      transaction: json['transaction'] != null
          ? TransactionResponse.fromJson(json['transaction'])
          : null,
      monthSummary: json['month_summary'] != null
          ? MonthSummary.fromJson(json['month_summary'])
          : null,
    );
  }
}

class MonthSummary {
  final int anio;
  final int mes;
  final String limite;
  final String gastoTotal;
  final String saldoDisponible;
  final String estado;

  MonthSummary({
    required this.anio,
    required this.mes,
    required this.limite,
    required this.gastoTotal,
    required this.saldoDisponible,
    required this.estado,
  });

  factory MonthSummary.fromJson(Map<String, dynamic> json) {
    return MonthSummary(
      anio: json['anio'] ?? 0,
      mes: json['mes'] ?? 0,
      limite: json['limite']?.toString() ?? '0.00',
      gastoTotal: json['gasto_total']?.toString() ?? '0.00',
      saldoDisponible: json['saldo_disponible']?.toString() ?? '0.00',
      estado: json['estado'] ?? 'abierto',
    );
  }
}
