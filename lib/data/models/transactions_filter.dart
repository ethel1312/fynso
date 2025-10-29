class TransactionsFilter {
  final int? categoryId;
  final int? subcategoryId;
  final DateTime? dateFrom;     // fecha pura (Y-M-D)
  final DateTime? dateTo;       // fecha pura (Y-M-D)
  final double? amountMin;
  final double? amountMax;

  const TransactionsFilter({
    this.categoryId,
    this.subcategoryId,
    this.dateFrom,
    this.dateTo,
    this.amountMin,
    this.amountMax,
  });

  TransactionsFilter copyWith({
    int? categoryId,
    int? subcategoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? amountMin,
    double? amountMax,
    bool clearCategory = false,
    bool clearSubcategory = false,
    bool clearDates = false,
    bool clearAmounts = false,
  }) {
    return TransactionsFilter(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      subcategoryId: clearSubcategory ? null : (subcategoryId ?? this.subcategoryId),
      dateFrom: clearDates ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDates ? null : (dateTo ?? this.dateTo),
      amountMin: clearAmounts ? null : (amountMin ?? this.amountMin),
      amountMax: clearAmounts ? null : (amountMax ?? this.amountMax),
    );
  }

  Map<String, String> toQueryParams() {
    final map = <String, String>{};
    if (categoryId != null) map['category_id'] = '$categoryId';
    if (subcategoryId != null) map['subcategory_id'] = '$subcategoryId';
    if (dateFrom != null) map['date_from'] = _fmt(dateFrom!);
    if (dateTo != null) map['date_to'] = _fmt(dateTo!);
    if (amountMin != null) map['amount_min'] = amountMin!.toString();
    if (amountMax != null) map['amount_max'] = amountMax!.toString();
    return map;
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
