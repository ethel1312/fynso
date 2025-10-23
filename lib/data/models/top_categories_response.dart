class TopCategoryItem {
  final String nombre;
  /// Monto llega como string "123.45" desde el backend
  final String monto;
  /// 0..1
  final double porcentaje;
  final String porcentajeFmt;

  TopCategoryItem({
    required this.nombre,
    required this.monto,
    required this.porcentaje,
    required this.porcentajeFmt,
  });

  factory TopCategoryItem.fromJson(Map<String, dynamic> json) {
    return TopCategoryItem(
      nombre: json['nombre'] ?? '',
      monto: json['monto'] ?? '0.00',
      porcentaje: (json['porcentaje'] is num)
          ? (json['porcentaje'] as num).toDouble()
          : double.tryParse('${json['porcentaje']}') ?? 0.0,
      porcentajeFmt: json['porcentaje_fmt'] ?? '',
    );
  }

  double get montoDouble => double.tryParse(monto) ?? 0.0;
}

class TopCategoriesResponse {
  final int anio;
  final int mes;
  final String total;
  final List<TopCategoryItem> items;

  TopCategoriesResponse({
    required this.anio,
    required this.mes,
    required this.total,
    required this.items,
  });

  factory TopCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final items = (data['items'] as List? ?? [])
        .map((e) => TopCategoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return TopCategoriesResponse(
      anio: data['month']?['anio'] ?? 0,
      mes: data['month']?['mes'] ?? 0,
      total: data['total'] ?? '0.00',
      items: items,
    );
  }
}
