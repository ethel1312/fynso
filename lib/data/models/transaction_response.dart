class TransactionResponse {
  final int idTransaction;
  final int idSubcategory;
  final int idTransactionType;
  final double monto;
  final String descripcion;
  final String fecha;
  final String? lugar;
  final String? transcripcion;

  // Para UI
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
        return value['nombre']?.toString() ?? fallback;
      }
      return value.toString();
    }

    // Manejar tanto formato "plano" como "anidado" (como devuelve tu backend)
    final nestedSub = (json['subcategory'] is Map<String, dynamic>) ? json['subcategory'] as Map<String, dynamic> : null;
    final nestedType = (json['transaction_type'] is Map<String, dynamic>) ? json['transaction_type'] as Map<String, dynamic> : null;

    final idSub = json.containsKey('id_subcategory')
        ? parseInt(json['id_subcategory'])
        : parseInt(nestedSub?['id_subcategory']);

    final idTType = json.containsKey('id_transaction_type')
        ? parseInt(json['id_transaction_type'])
        : parseInt(nestedType?['id_transaction_type']);

    return TransactionResponse(
      idTransaction: parseInt(json['id_transaction']),
      idSubcategory: idSub,
      idTransactionType: idTType,
      monto: parseDouble(json['monto']),
      descripcion: json['descripcion'] ?? '',
      fecha: json['fecha'] ?? '',
      lugar: json['lugar'],
      transcripcion: json['transcripcion'],
      category: parseString(json['category'], fallback: 'Otros'),
      subcategory: parseString(json['subcategory'], fallback: 'General'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_transaction': idTransaction,
      'id_subcategory': idSubcategory,
      'id_transaction_type': idTransactionType,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha,
      'lugar': lugar,
      'transcripcion': transcripcion,
      'category': category,
      'subcategory': subcategory,
    };
  }
}
