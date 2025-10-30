class MonthlySpendingTrendItem {
  final int anio;
  final int mes;
  final String gastoTotal; // "0.00"
  final String prevGastoTotal; // "0.00"
  final String delta; // "0.00"
  final String? pctChange; // "12.34" o null
  final String? pctChangeFmt; // "12.34%" o null
  final String trend; // sube | baja | igual | sube_desde_cero

  MonthlySpendingTrendItem({
    required this.anio,
    required this.mes,
    required this.gastoTotal,
    required this.prevGastoTotal,
    required this.delta,
    required this.pctChange,
    required this.pctChangeFmt,
    required this.trend,
  });

  factory MonthlySpendingTrendItem.fromJson(Map<String, dynamic> j) {
    return MonthlySpendingTrendItem(
      anio: j['anio'] as int,
      mes: j['mes'] as int,
      gastoTotal: (j['gasto_total'] ?? '0.00').toString(),
      prevGastoTotal: (j['prev_gasto_total'] ?? '0.00').toString(),
      delta: (j['delta'] ?? '0.00').toString(),
      pctChange: j['pct_change']?.toString(),
      pctChangeFmt: j['pct_change_fmt']?.toString(),
      trend: (j['trend'] ?? 'igual').toString(),
    );
  }
}

class MonthlySpendingTrendResponse {
  final int fromYear;
  final int fromMonth;
  final int toYear;
  final int toMonth;
  final List<MonthlySpendingTrendItem> items;

  MonthlySpendingTrendResponse({
    required this.fromYear,
    required this.fromMonth,
    required this.toYear,
    required this.toMonth,
    required this.items,
  });

  factory MonthlySpendingTrendResponse.fromJson(Map<String, dynamic> j) {
    final data = j['data'] as Map<String, dynamic>;
    final from = data['from'] as Map<String, dynamic>;
    final to = data['to'] as Map<String, dynamic>;
    final list = (data['items'] as List? ?? [])
        .map((e) => MonthlySpendingTrendItem.fromJson(e))
        .toList();
    return MonthlySpendingTrendResponse(
      fromYear: from['anio'] as int,
      fromMonth: from['mes'] as int,
      toYear: to['anio'] as int,
      toMonth: to['mes'] as int,
      items: list,
    );
  }
}


