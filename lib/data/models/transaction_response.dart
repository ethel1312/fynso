class TransactionResponse {
  final int idTransaction;
  final int idSubcategory;
  final int idTransactionType;
  final double monto;
  final String descripcion;
  final String fecha;
  final String? lugar;
  final String? transcripcion;

  // Opcional: campos derivados para UI
  final String category;
  final String subcategory;

  TransactionResponse({
    required this.idTransaction,
    required this.idSubcategory,
    required this.idTransactionType,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    this.lugar,
    this.transcripcion,
    required this.category,
    required this.subcategory,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    String parseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        // Intentamos tomar la propiedad "nombre" si existe
        return value['nombre']?.toString() ?? fallback;
      }
      return value.toString();
    }

    return TransactionResponse(
      idTransaction: parseInt(json['id_transaction']),
      idSubcategory: parseInt(json['id_subcategory']),
      idTransactionType: parseInt(json['id_transaction_type']),
      monto: parseDouble(json['monto']),
      descripcion: json['descripcion'] ?? '',
      fecha: json['fecha'] ?? '',
      lugar: json['lugar'],
      transcripcion: json['transcripcion'],
      category: parseString(json['category'], fallback: 'Otros'),
      subcategory: parseString(json['subcategory'], fallback: 'General'),
    );
  }
}
