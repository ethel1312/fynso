class TransactionUpdateRequest {
  final String? category;
  final String? subcategory;
  final double amount;
  final String date;
  final String time;
  final String place;
  final String notes;
  final int? idSubcategory; // 👈 nuevo

  TransactionUpdateRequest({
    this.category,
    this.subcategory,
    required this.amount,
    required this.date,
    required this.time,
    required this.place,
    required this.notes,
    this.idSubcategory,
  });

  Map<String, dynamic> toJson() => {
    if (category != null) 'category': category,
    if (subcategory != null) 'subcategory': subcategory,
    'amount': amount,
    'date': date,
    'time': time,
    'place': place,
    'notes': notes,
    if (idSubcategory != null) 'id_subcategory': idSubcategory, // 👈 clave esperada por el backend
  };
}
