class MonthlySummary {
  final int anio;
  final int mes;
  final String limite;          // "0.00"
  final String gastoTotal;      // "123.45"
  final String saldoDisponible; // "..."
  final String estado;          // "abierto" | "cerrado"

  MonthlySummary({
    required this.anio,
    required this.mes,
    required this.limite,
    required this.gastoTotal,
    required this.saldoDisponible,
    required this.estado,
  });

  factory MonthlySummary.fromApi(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return MonthlySummary(
      anio: data['anio'] ?? 0,
      mes: data['mes'] ?? 0,
      limite: data['limite'] ?? '0.00',
      gastoTotal: data['gasto_total'] ?? '0.00',
      saldoDisponible: data['saldo_disponible'] ?? '0.00',
      estado: data['estado'] ?? 'abierto',
    );
  }

  double get limiteDouble => double.tryParse(limite) ?? 0.0;
  double get gastoDouble  => double.tryParse(gastoTotal) ?? 0.0;
  double get saldoDouble  => double.tryParse(saldoDisponible) ?? 0.0;
}
