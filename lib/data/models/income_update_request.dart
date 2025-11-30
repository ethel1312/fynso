class IncomeUpdateRequest {
  final double amount;
  final String date; // "yyyy-MM-dd"
  final String time; // "HH:mm"
  final String? notes;

  IncomeUpdateRequest({
    required this.amount,
    required this.date,
    required this.time,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date,
      'time': time,
      'notes': notes,
    };
  }
}
