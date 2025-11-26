class IncomeRequest {
  final double amount;
  final String date;
  final String time;
  final String? notes;

  IncomeRequest({
    required this.amount,
    required this.date,
    required this.time,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {"amount": amount, "date": date, "time": time, "notes": notes};
  }
}
