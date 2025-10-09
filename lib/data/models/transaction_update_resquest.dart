class TransactionUpdateRequest {
  final double? amount;
  final String? category;
  final String? subcategory;
  final String? date; // "YYYY-MM-DD"
  final String? time; // "HH:mm"
  final String? place;
  final String? notes;

  TransactionUpdateRequest({
    this.amount,
    this.category,
    this.subcategory,
    this.date,
    this.time,
    this.place,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (amount != null) json['amount'] = amount;
    if (category != null) json['category'] = category;
    if (subcategory != null) json['subcategory'] = subcategory;
    if (date != null) json['date'] = date;
    if (time != null) json['time'] = time;
    if (place != null) json['place'] = place;
    if (notes != null) json['notes'] = notes;
    return json;
  }
}
