// lib/data/models/transaction_detail_response.dart
import 'package:fynso/data/models/transaction_response.dart';

class TransactionDetailResponse {
  final int idTransaction;
  final double monto;
  final String descripcion;
  final String fecha;
  final String? lugar;
  final String? transcripcion;

  final Subcategory subcategory;
  final Category category;
  final TransactionType transactionType;

  TransactionDetailResponse({
    required this.idTransaction,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    this.lugar,
    this.transcripcion,
    required this.subcategory,
    required this.category,
    required this.transactionType,
  });

  factory TransactionDetailResponse.fromJson(Map<String, dynamic> json) {
    return TransactionDetailResponse(
      idTransaction: json['id_transaction'],
      monto: double.parse(json['monto'].toString()),
      descripcion: json['descripcion'] ?? '',
      fecha: json['fecha'] ?? '',
      lugar: json['lugar'],
      transcripcion: json['transcripcion'],
      subcategory: Subcategory.fromJson(json['subcategory']),
      category: Category.fromJson(json['category']),
      transactionType: TransactionType.fromJson(json['transaction_type']),
    );
  }
}

class Subcategory {
  final int id;
  final String nombre;

  Subcategory({required this.id, required this.nombre});

  factory Subcategory.fromJson(Map<String, dynamic> json) =>
      Subcategory(id: json['id_subcategory'], nombre: json['nombre']);
}

class Category {
  final int id;
  final String nombre;

  Category({required this.id, required this.nombre});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json['id_category'], nombre: json['nombre']);
}

class TransactionType {
  final int id;
  final String nombre;

  TransactionType({required this.id, required this.nombre});

  factory TransactionType.fromJson(Map<String, dynamic> json) =>
      TransactionType(id: json['id_transaction_type'], nombre: json['nombre']);
}

extension TransactionDetailExtension on TransactionDetailResponse {
  TransactionResponse toTransactionResponse() {
    return TransactionResponse(
      idTransaction: idTransaction,
      idSubcategory: subcategory.id,
      idTransactionType: transactionType.id,
      monto: monto,
      descripcion: descripcion,
      fecha: fecha,
      lugar: lugar,
      transcripcion: transcripcion,
      category: category.nombre,
      subcategory: subcategory.nombre,
    );
  }
}
