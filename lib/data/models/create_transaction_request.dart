class CreateTransactionRequest {
  final double amount;
  final int? idSubcategory;
  final String? category;
  final String? subcategory;
  final String? date;
  final String? time;
  final String? place;
  final String? notes;

  CreateTransactionRequest({
    required this.amount,
    this.idSubcategory,
    this.category,
    this.subcategory,
    this.date,
    this.time,
    this.place,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'amount': amount,
    };

    if (idSubcategory != null) {
      json['id_subcategory'] = idSubcategory;
    }
    if (category != null && category!.isNotEmpty) {
      json['category'] = category;
    }
    if (subcategory != null && subcategory!.isNotEmpty) {
      json['subcategory'] = subcategory;
    }
    if (date != null && date!.isNotEmpty) {
      json['date'] = date;
    }
    if (time != null && time!.isNotEmpty) {
      json['time'] = time;
    }
    if (place != null && place!.isNotEmpty) {
      json['place'] = place;
    }
    if (notes != null && notes!.isNotEmpty) {
      json['notes'] = notes;
    }

    return json;
  }
}
